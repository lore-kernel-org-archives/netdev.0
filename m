From: Roland Stigge <stigge@antcom.de>
Subject: Re: [PATCH v5] lpc32xx: Added ethernet driver
Date: Wed, 07 Mar 2012 12:53:28 +0100
Message-ID: <4F574C38.4030006@antcom.de>
References: <1331067664-9124-1-git-send-email-stigge@antcom.de> <201203062134.38077.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	alexander.h.duyck@intel.com, eilong@broadcom.com,
	ian.campbell@citrix.com, netdev@vger.kernel.org,
	w.sang@pengutronix.de, linux-kernel@vger.kernel.org,
	kevin.wells@nxp.com, linux-arm-kernel@lists.infradead.org,
	baruch@tkos.co.il, joe@perches.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201203062134.38077.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Arnd,

On 03/06/2012 10:34 PM, Arnd Bergmann wrote:
> This should eventually both become run-time options based on the device tree.
> I don't know if you planned to do that anyway, but if you want the same kernel
> binary to be used for systems in different configurations, you cannot have
> compile-time decisions that are exclusive-or. Since you don't support device
> tree yet but plan to do that in the future, you could add a comment here
> about it, or you could even prepare it for that case already by passing the
> device into the functions that will be required for reading the properties.

Good point.

I prefer putting a comment for now, because upon the planned device tree
introduction in lpc32xx, an internal change in lpc_eth.c will be
necessary anyway, so there is no need to already introduce unused
parameters at this point.

Thanks,

Roland
