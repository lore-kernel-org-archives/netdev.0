From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v1 5/5] driver-core: add driver asynchronous probe support
Date: Mon, 29 Sep 2014 18:24:45 -0400
Message-ID: <20140929222445.GA10280@kroah.com>
References: <1411768637-6809-1-git-send-email-mcgrof@do-not-panic.com>
 <1411768637-6809-6-git-send-email-mcgrof@do-not-panic.com>
 <20140928150329.GC5023@mtj.dyndns.org>
 <20140929212208.GV17349@wotan.suse.de>
 <20140929215945.GA1628@kroah.com>
 <CAB=NE6XKeoDnnBxupLSAXz9w3TXVgAW+Yw3o8-ugzzUgH7j13A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Takashi Iwai <tiwai@suse.de>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Tom Gundersen <teg@jklm.no>, rmilasan@suse.com,
	werner@suse.com, Oleg Nesterov <oleg@redhat.com>,
	hare <hare@suse.com>, Benjamin Poirier <bpoirier@suse.de>,
	Santosh Rastapur <santosh@chelsio.com>,
	Petr Mladek <pmladek@suse.cz>, dbueso@suse.com,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech
To: "Luis R. Rodriguez" <mcgrof@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAB=NE6XKeoDnnBxupLSAXz9w3TXVgAW+Yw3o8-ugzzUgH7j13A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 29, 2014 at 03:10:22PM -0700, Luis R. Rodriguez wrote:
> On Mon, Sep 29, 2014 at 2:59 PM, Greg KH <gregkh@linuxfoundation.org> wrote:
> >> Sure make sense, I wasn't quite sure how to make this quite clear,
> >> a naming convention seems good to me but I also had added at least
> >> a print about this on the log. Ideally I think a TAIN_DEBUG would
> >> be best and it seems it could be useful for many other cases in
> >> the kernel, we could also just re-use TAINT_CRAP as well. Thoughts?
> >> Greg?
> >
> > TAINT_CRAP is for drivers/staging/ code, don't try to repurpose it for
> > some other horrid option.  There's no reason we can't add more taint
> > flags for this.
> 
> OK thanks, I'll add TAINT_DEBUG. Any preference where to stuff struct
> driver_attach_work *attach_work ? On the private data structure as
> this patch currently implements, saving us 24 bytes and hiding it from
> drivers, or stuffing it on the device driver and simplifying the core
> code?

I honestly haven't even looked at this series, sorry.  It's too late
near the close of the merge window for 3.18 and have been on the road
for the past week in France.

greg k-h
