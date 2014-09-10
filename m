From: Ceriel Jacobs <linux-scsi@crashplan.pro>
Subject: Re: [systemd-devel] [RFC v2 3/6] kthread: warn on kill signal if
 not OOM
Date: Wed, 10 Sep 2014 12:07:48 +0200
Message-ID: <541022F4.4020501@crashplan.pro>
References: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com> <CAB=NE6Wti1RpAFk5q_YeZn2F9Rd=wsiwhyPszu74nG9fXwH5vQ@mail.gmail.com> <20140905141241.GC10455@mtj.dyndns.org> <20140905164405.GA28964@core.coreip.homeip.net> <20140905174925.GA12991@mtj.dyndns.org> <CAB=NE6VPTV39pNujOgO422wbUvU44HZ7s=aaxPVraNECqA6e4Q@mail.gmail.com> <20140905224047.GC15723@mtj.dyndns.org> <CAB=NE6Uz1VD5qpMFSBfQRV8ih9FQcCUhNtWMvD38t5hdDvix4Q@mail.gmail.com> <20140909011059.GB11706@mtj.dyndns.org> <1410241109.2028.22.camel@jarvis.lan> <CAB=NE6WGAMvffGDTkN5x5Cd+YOtD-Cmo3v7_8FmJ5cvCRbFEpw@mail.gmail.com> <1410291346.13298.16.camel@jarvis.lan> <CAB=NE6U6v-GhAaZv3yXn9uVFvBvE4Uq8z7MQU8N+CyW19WpnNQ@mail.gmail.com> <CAG-2HqUiUksdT4UyeDsdc1Q74=2BiX2TuzzGh_hoLiO5_DOvXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Takashi Iwai <tiwai@suse.de>, Kay Sievers <kay@vrfy.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	hare <hare@suse.com>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Wu Zhangjin <falcon@meizu.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	"mpt-fusionlinux.pdl" <MPT-FusionLinux.pdl@avagotech.com>,
	Tim Gardner <tim.gardner@canonical.com>,
	Benjamin Poirier <bpoirier@suse.de>,
	Santosh Rastapur <santosh@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	Hariprasad S <hariprasad@chelsio.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
	systemd Mailin
To: Tom Gundersen <teg@jklm.no>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAG-2HqUiUksdT4UyeDsdc1Q74=2BiX2TuzzGh_hoLiO5_DOvXQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tom Gundersen schreef op 10-09-14 om 08:46:
>> >Indeed. What I proposed with a multiplier for the timeout for the
>> >different types of built in commands was deemed complex but saw no
>> >alternatives proposed despite my interest to work on one and
>> >clarifications noted that this was a design regression. Not quite sure
>> >what else I could have done here. I'm interested in learning what the
>> >better approach is for the future as if we want to marry init + kernel
>> >we need a smooth way for us to discuss design without getting worked
>> >up about it, or taking it personal. I really want this to work as I
>> >personally like systemd so far.
> How about this: keep the timeout global, but also introduce a
> (relatively short, say 10 or 15 seconds) timeout after which a warning
> is printed. Even if nothing is actually killed, having workers (be it
> insmod or something else) take longer than a couple of seconds is
> likely a sign that something is seriously off somewhere.

I don't agree with the statement that something is seriously off when it 
takes more then 10 to 15 seconds.

When probing only one hard disk drive, then I do agree that something is 
seriously off after 10 to 15 seconds.

When probing a SAS bus with one hundred hard disk drives in standby 
mode, then I do expect that to take longer then 10 to 15 seconds.
