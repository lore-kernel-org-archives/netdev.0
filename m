From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: Re: [PATCH 0/8] validate MAC address before call .ndo_set_mac_address
Date: Wed, 29 Feb 2012 17:24:05 +0100
Message-ID: <201202291724.06641.danny.kukawka@bisect.de>
References: <1330530176-24952-1-git-send-email-danny.kukawka@bisect.de> <1330531139.8460.192.camel@deadeye> <201202291714.43843.danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201202291714.43843.danny.kukawka@bisect.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mittwoch, 29. Februar 2012, Danny Kukawka wrote:
> On Mittwoch, 29. Februar 2012, you wrote:
> > On Wed, 2012-02-29 at 16:42 +0100, Danny Kukawka wrote:
> > > Validate the given MAC address directly in dev_set_mac_address()
> > > if a .ndo_validate_addr function is available before calling
> > > the .ndo_set_mac_address function.
> > >
> > > Changed .ndo_validate_addr to take a second parameter containing
> > > a sockaddr struct to be checked instead of the net_device dev_addr.
> > > The behaviour of .ndo_validate_addr is now: if the second parameter
> > > is NULL the net_device->dev_addr gets validate, if != NULL
> > > the given parameter/sockaddr gets validated instead.
> > >
> > > This patch series include adaptations for some drivers which
> > > use .ndo_set_mac_address functions directly - to prevent double
> > > checks and to enable validations via .ndo_validate_addr.
> >
> > [...]
> >
> > You have to do this as a single patch.  The kernel and drivers should
> > still build at each stage.
>
> Okay. In this case only patch 1 and 2 needs to be merged into one
> commit/patch since the other will even work with out patch one or two. I
> will send a new version of the series as soon as I get more comments on the
> content.

I have to send a new version anyway since I've accidently forgot to run 
checkpatch.pl. Sorry.

Danny
