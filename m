From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [RFC v2 1/2] PCI-Express Non-Transparent Bridge Support
Date: Tue, 31 Jul 2012 14:02:25 -0400
Message-ID: <CAAsGZS4nhv+s7NVwaaGjQ9fJoHQoaXnUoYw=xTPC-sfen+tj8A@mail.gmail.com>
References: <1343607994-32415-1-git-send-email-jon.mason@intel.com>
	<1343607994-32415-2-git-send-email-jon.mason@intel.com>
	<CAErSpo4p_hxvCeVGqiTXVq3itXepheQZerpqRHwLvG6A7R2Lcg@mail.gmail.com>
	<20120730181542.GA987@jonmason-lab>
	<CAErSpo6gjMf4C3RMn5YLNg5JtJ8CjHvTw1iqsKPa6YuRqPe90g@mail.gmail.com>
	<CAAsGZS5kOyQ5FQ7Jg3HxOmmPNYS+F6XcB-_3tm=rcgDV7wAvRQ@mail.gmail.com>
	<20120731172709.GB14080@jonmason-lab>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>
To: Jon Mason <jon.mason@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120731172709.GB14080@jonmason-lab>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 31, 2012 at 1:27 PM, Jon Mason <jon.mason@intel.com> wrote:
>
> I don't see the benefit of having the driver in staging.  Any vendors
> who would notice the ntb driver in staging would be sitting on these
> mailing lists and hopefully have planety of comments on the design.
> Stashing the driver in staging while waiting for these comments (which
> may never come) doesn't seem the best course of action.
>

I thought that since others are talking about it then may be there is
some WIP code for foo-NTB. Seems like that's not the case. So no need
to stage.

Correct me if I'm wrong but wouldn't apps just open a socket and route
data via ntb_vir_eth_dev? So I don't see an ABI breakage issue and
hence nothing would prevent us from changing the kernel parts(for
accommodating some foo-NTB part) in future.

It may not be a bad idea to prefix intel-specific(if any)
ntb_structs/variables/logic with the 'intc'(Intel ticker or pick your
string) keyword.

Chetan Loke
