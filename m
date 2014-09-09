From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Tue, 9 Sep 2014 10:13:02 +0900
Message-ID: <20140909011302.GC11706@mtj.dyndns.org>
References: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com>
 <CAB=NE6Wti1RpAFk5q_YeZn2F9Rd=wsiwhyPszu74nG9fXwH5vQ@mail.gmail.com>
 <20140905141241.GC10455@mtj.dyndns.org>
 <20140905164405.GA28964@core.coreip.homeip.net>
 <20140905174925.GA12991@mtj.dyndns.org>
 <CAB=NE6VPTV39pNujOgO422wbUvU44HZ7s=aaxPVraNECqA6e4Q@mail.gmail.com>
 <20140905224047.GC15723@mtj.dyndns.org>
 <CAB=NE6Uz1VD5qpMFSBfQRV8ih9FQcCUhNtWMvD38t5hdDvix4Q@mail.gmail.com>
 <20140909011059.GB11706@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay@vrfy.org>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Wu Zhangjin <falcon@meizu.com>, Takashi Iwai <tiwai@suse.de>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Oleg Nesterov <oleg@redhat.com>, hare@suse.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Benjamin Poirier <bpoirier@suse.de>,
	Santosh Rastapur <santosh@chelsio.com>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Redd
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140909011059.GB11706@mtj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 09, 2014 at 10:10:59AM +0900, Tejun Heo wrote:
> * Identify cases which can't be asynchronous and make them
>   synchronous.  e.g. keep who's doing request_module() and avoid
>   asynchronous probing if current is probing one of those.

That wouldn't work as we don't know what's gonna happen in userland
but we can start with just disallowing async probing for char devices
for now.

Thanks.

-- 
tejun
