From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] wimax/i2400m: Remove VLAIS
Date: Wed, 25 Oct 2017 12:39:00 -0500
Message-ID: <1508953140.23414.1.camel@redhat.com>
References: <20171009194153.30467-1-mka@chromium.org>
         ,<20171024194659.GC96615@google.com>
         <3A78FAA0EC814D4B8ECC99B3AB32B332843B9D96@fmsmsx104.amr.corp.intel.com>
        ,<1508947039.19417.0.camel@redhat.com>
         <3A78FAA0EC814D4B8ECC99B3AB32B332843BB118@fmsmsx104.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wimax <linux-wimax@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Behan Webster <behanw@converseincode.com>,
        Mark Charlebois <charlebm@gmail.com>,
        Arnd Bergmann <arnd@arndb.de>,
        Guenter Roeck <groeck@chromium.org>
To: "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez@intel.com>,
        Matthias Kaehlcke <mka@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3A78FAA0EC814D4B8ECC99B3AB32B332843BB118@fmsmsx104.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-10-25 at 17:12 +0000, Perez-Gonzalez, Inaky wrote:
> > On Tue, 2017-10-24 at 21:00 +0000, Perez-Gonzalez, Inaky wrote:
> > > > ping any comments on this?
> > > 
> > > None from me; I don't have access to this HW anymore, so I can't
> > > validate if the change would work or not.
> > I still have a 5350 around somewhere, I can make sure firmware
> > loads if
> > you like.
> 
> That'd be swell Dan, thx

Seems to load firmware, read the MAC, and reboot the card.  Couldn't
get userspace tools working in a 5m try but the kernel module debug
traces indicate the card TX/RX-es commands and we can pull out the card
state and rfkill status and things like that.

Inaky, is that enough to verify the patch is OK?

Dan
