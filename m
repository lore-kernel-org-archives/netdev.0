From: Jon Mason <jon.mason@intel.com>
Subject: Re: [RFC v2 1/2] PCI-Express Non-Transparent Bridge Support
Date: Tue, 31 Jul 2012 10:27:09 -0700
Message-ID: <20120731172709.GB14080@jonmason-lab>
References: <1343607994-32415-1-git-send-email-jon.mason@intel.com>
 <1343607994-32415-2-git-send-email-jon.mason@intel.com>
 <CAErSpo4p_hxvCeVGqiTXVq3itXepheQZerpqRHwLvG6A7R2Lcg@mail.gmail.com>
 <20120730181542.GA987@jonmason-lab>
 <CAErSpo6gjMf4C3RMn5YLNg5JtJ8CjHvTw1iqsKPa6YuRqPe90g@mail.gmail.com>
 <CAAsGZS5kOyQ5FQ7Jg3HxOmmPNYS+F6XcB-_3tm=rcgDV7wAvRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>
To: chetan loke <loke.chetan@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAAsGZS5kOyQ5FQ7Jg3HxOmmPNYS+F6XcB-_3tm=rcgDV7wAvRQ@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 31, 2012 at 12:02:20PM -0400, chetan loke wrote:
> On Tue, Jul 31, 2012 at 9:45 AM, Bjorn Helgaas <bhelgaas@google.com> wrote:
> > On Mon, Jul 30, 2012 at 12:15 PM, Jon Mason <jon.mason@intel.com> wrote:
> >>
> >> I've tried to make it all generic enough that non-Intel NTBs should plug in with
> >> minimal changes to ntb_hw.c.  If their design is too divergent, then a slight
> >> redesign of ntb_hw.c might be necessary.  But from what I've seen of other
> >> designs on the internet, they appear to be extremely similar.  The transport and
> >> client drivers were written with the hardware abstracted away as much as
> >> possible to prevent the need to modify it for different hardware.  If there is
> >> anything which is Intel hardware specific, I'd be happy to change it to make it
> >> more generic.
> >
> > That makes sense from a technical point of view, but I think it's
> > going to cause maintenance issues.  For example, assume PLX NTB
> > support is added.  Will PLX be happy about having to convince you to
> > accept changes?  Will Intel be happy about having to release a new
> 
> Do you mean convince Intel? Well, if we think of ntb as the class
> driver then the onus is on the community to vet the changes and NOT
> intel.
> And since this is the first NTB part for which the support is
> introduced the class driver design could be a moving target. As
> someone else mentioned, the async/sync tx-dma is another hook that
> could change the class driver's design.
> 
> 
> > driver for their hardware just to incorporate a PLX bug fix?  Will
> > users of PLX hardware accept a new driver release that only benefits
> > Intel users?
> 
> May be till the class driver is stable, the client(intel/PLX) drivers
> might have to be modified.  This is a cue for other vendors to
> chime-in and review this design?
> Just thinking if this could sit in staging for some time(so that
> others get a chance to review/suggest changes as well) and then get
> promoted out of staging.

I don't see the benefit of having the driver in staging.  Any vendors
who would notice the ntb driver in staging would be sitting on these
mailing lists and hopefully have planety of comments on the design.
Stashing the driver in staging while waiting for these comments (which
may never come) doesn't seem the best course of action.

Thanks,
Jon

> 
> Chetan Loke
