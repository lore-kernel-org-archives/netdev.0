From: Tom Gundersen <teg@jklm.no>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Wed, 10 Sep 2014 07:13:41 +0200
Message-ID: <CAG-2HqUhvFJeuqUmtqSDq9hnRnt3L9tOvr777xkmFaQWaiMk6g@mail.gmail.com>
References: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com>
 <CAB=NE6Wti1RpAFk5q_YeZn2F9Rd=wsiwhyPszu74nG9fXwH5vQ@mail.gmail.com>
 <20140905141241.GC10455@mtj.dyndns.org> <20140905164405.GA28964@core.coreip.homeip.net>
 <20140905174925.GA12991@mtj.dyndns.org> <CAB=NE6VPTV39pNujOgO422wbUvU44HZ7s=aaxPVraNECqA6e4Q@mail.gmail.com>
 <20140905224047.GC15723@mtj.dyndns.org> <CAB=NE6Uz1VD5qpMFSBfQRV8ih9FQcCUhNtWMvD38t5hdDvix4Q@mail.gmail.com>
 <20140909011059.GB11706@mtj.dyndns.org> <20140909012227.GE11706@mtj.dyndns.org>
 <CAB=NE6Vn3hA_VKJyi4kgMi6iMtTtA104-_UfFm6vgX14RoDOTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tejun Heo <tj@kernel.org>,
	Lennart Poettering <lennart@poettering.net>,
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
	Praveen Krishnamoorthy <praveen.krishnamoorthy@ava
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAB=NE6Vn3hA_VKJyi4kgMi6iMtTtA104-_UfFm6vgX14RoDOTw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 9, 2014 at 3:26 AM, Luis R. Rodriguez
<mcgrof@do-not-panic.com> wrote:
> On Mon, Sep 8, 2014 at 6:22 PM, Tejun Heo <tj@kernel.org> wrote:
>> On Tue, Sep 09, 2014 at 10:10:59AM +0900, Tejun Heo wrote:
>>> I'm not too convinced this is such a difficult problem to figure out.
>>> We already have most of logic in place and the only thing missing is
>>> how to switch it.  Wouldn't something like the following work?
>>>
>>> * Add a sysctl knob to enable asynchronous device probing on module
>>>   load and enable asynchronous probing globally if the knob is set.
>>
>> Alternatively, add a module-generic param "async_probe" or whatever
>> and use that to switch the behavior should work too.  I don't know
>> which way is better but either should work fine.
>
> I take it by this you meant a generic system-wide sysctl or kernel cmd
> line option to enable this for al drivers?

If the expectation is that this feature should be enabled
unconditionally for all systemd systems, wouldn't it make more sense
to make it a Kconfig option (possibly overridable from the kernel
commandline in case that makes testing simpler)?

Cheers,

Tom
