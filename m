From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [RFC v2 1/2] PCI-Express Non-Transparent Bridge Support
Date: Tue, 31 Jul 2012 11:03:40 -0600
Message-ID: <CAErSpo5VdOtBfkfLg+e9dL=ZMd2tpWfEninuEcuURuet8jRc8Q@mail.gmail.com>
References: <1343607994-32415-1-git-send-email-jon.mason@intel.com>
 <1343607994-32415-2-git-send-email-jon.mason@intel.com> <CAErSpo4p_hxvCeVGqiTXVq3itXepheQZerpqRHwLvG6A7R2Lcg@mail.gmail.com>
 <20120730181542.GA987@jonmason-lab> <CAErSpo6gjMf4C3RMn5YLNg5JtJ8CjHvTw1iqsKPa6YuRqPe90g@mail.gmail.com>
 <CAAsGZS5kOyQ5FQ7Jg3HxOmmPNYS+F6XcB-_3tm=rcgDV7wAvRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jon Mason <jon.mason@intel.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>
To: chetan loke <loke.chetan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAsGZS5kOyQ5FQ7Jg3HxOmmPNYS+F6XcB-_3tm=rcgDV7wAvRQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 31, 2012 at 10:02 AM, chetan loke <loke.chetan@gmail.com> wrote:
> On Tue, Jul 31, 2012 at 9:45 AM, Bjorn Helgaas <bhelgaas@google.com> wrote:
>> On Mon, Jul 30, 2012 at 12:15 PM, Jon Mason <jon.mason@intel.com> wrote:
>>>
>>> I've tried to make it all generic enough that non-Intel NTBs should plug in with
>>> minimal changes to ntb_hw.c.  If their design is too divergent, then a slight
>>> redesign of ntb_hw.c might be necessary.  But from what I've seen of other
>>> designs on the internet, they appear to be extremely similar.  The transport and
>>> client drivers were written with the hardware abstracted away as much as
>>> possible to prevent the need to modify it for different hardware.  If there is
>>> anything which is Intel hardware specific, I'd be happy to change it to make it
>>> more generic.
>>
>> That makes sense from a technical point of view, but I think it's
>> going to cause maintenance issues.  For example, assume PLX NTB
>> support is added.  Will PLX be happy about having to convince you to
>> accept changes?  Will Intel be happy about having to release a new
>
> Do you mean convince Intel? Well, if we think of ntb as the class
> driver then the onus is on the community to vet the changes and NOT
> intel.

No, I said convince "you," meaning *Jon*.  Intel doesn't apply
patches.  "The community" doesn't apply patches.  Jon applies patches.
 This has nothing to do with the fact that Jon is employed by Intel.
The point is that when you have multiple organizations involved, they
have different goals, markets, customers, and schedules.  If one
module contains both Intel-specific and PLX-specific things, that's a
place where these organizational differences may cause issues,
regardless of who is applying the patches.

Obviously it's not a problem now, and maybe it will never be.  But I
think there's a possibility.  Since I have no direct interest in any
of these devices, I'm only raising that possibility, not trying to
force any particular direction.
