From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] r8152: add Linksys USB3GIGV1 id
Date: Tue, 26 Sep 2017 09:35:15 +0200
Message-ID: <20170926073515.GB8108@kroah.com>
References: <20170922190604.108155-1-grundler@chromium.org>
 <1506351074.7827.13.camel@suse.com>
 <CANEJEGtM+gFC9Ofmp=UmGn5pKys9NRbsC6+ks_VqaLKWkEBS8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oliver Neukum <oneukum@suse.com>,
        Hayes Wang <hayeswang@realtek.com>,
        "David S . Miller" <davem@davemloft.net>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-usb <linux-usb@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Grant Grundler <grundler@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CANEJEGtM+gFC9Ofmp=UmGn5pKys9NRbsC6+ks_VqaLKWkEBS8A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 25, 2017 at 01:17:32PM -0700, Grant Grundler wrote:
> Correct. r8152 happens to claim the device before cdc_ether does - I
> thought because cdc_ether is a class driver and only gets picked up
> after vendor specific drivers are probed.  Is that correct?

Nope, there is not "priority" scheme of binding some drivers to devices
instead of others at all in Linux.  The whole scheme is "first in the
list", and has always been that way.

And yes, people have talked about changing this for decades now, but no
one has come up with any working patch, for the obvious reasons[1].

thanks,

greg k-h

[1] exercise is left for the reader :)
