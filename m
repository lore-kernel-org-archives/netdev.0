From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Thu, 11 Sep 2014 14:08:15 -0700
Message-ID: <CAB=NE6U8LQPFw4K+QabSppoLyife-oSX1h5vys5S7dqBj8ANLw@mail.gmail.com>
References: <20140905174925.GA12991@mtj.dyndns.org> <20140909224143.GB3154@mtj.dyndns.org>
 <1410302783.13298.50.camel@jarvis.lan> <5762134.BLS0EbmNJd@dtor-glaptop>
 <1410465565.10549.19.camel@jarvis> <20140911202354.GA2598@core.coreip.homeip.net>
 <CAB=NE6XfUAm=iVr=qfu5i9QW7BpViXfJ6wsmEZOOmS=rBF1bdA@mail.gmail.com> <20140911205308.GB2598@core.coreip.homeip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>,
	Tejun Heo <tj@kernel.org>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay@vrfy.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Wu Zhangjin <falcon@meizu.com>, Takashi Iwai <tiwai@suse.de>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Oleg Nesterov <oleg@redhat.com>, hare <hare@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Benjamin Poirier <bpoirier@suse.de>,
	Santosh Rastapur <santosh@chelsio.com>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140911205308.GB2598@core.coreip.homeip.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 11, 2014 at 1:53 PM, Dmitry Torokhov
<dmitry.torokhov@gmail.com> wrote:
> On Thu, Sep 11, 2014 at 01:42:20PM -0700, Luis R. Rodriguez wrote:
>> On Thu, Sep 11, 2014 at 1:23 PM, Dmitry Torokhov
>> <dmitry.torokhov@gmail.com> wrote:
>> >
>> >>  There are elements in common, but by and
>> >> large the biggest headaches at least in large device number boots have
>> >> already been tackled by the enterprise crowd (they don't like their
>> >> S390's or 1024 core NUMA systems taking half an hour to come up).
>> >
>> > Please do not position this as a mostly solved large systems problem,
>> > For us it is touchpad detection stalling kernel for 0.5-1 sec. Which is
>> > a lot given that we boot in seconds.
>>
>> Dmitry, would working on top of the aysnc series be reasonable? Then
>> we could address these as separate things which we'd build on top of.
>> The one aspect I see us needing to share is the "async probe universe
>> is OK" flag.
>
> Sure. Are you planning on refreshing your series?

Yes.

> I think the code-related discussion kind of stalled...

I was just waiting for any possible brain farts to flush out before a
new respin. I'll tackle this now.

 Luis
