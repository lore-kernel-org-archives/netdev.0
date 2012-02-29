From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: [PATCH 2/8] bnx2x: adopt bnx2x_validate_addr() to
 .ndo_validate_addr changes
Date: Wed, 29 Feb 2012 19:16:28 +0200
Message-ID: <1330535788.25281.3.camel@lb-tlvb-dmitry>
References: <1330530176-24952-1-git-send-email-danny.kukawka@bisect.de>
 <1330530176-24952-3-git-send-email-danny.kukawka@bisect.de>
 <1330532535.25281.2.camel@lb-tlvb-dmitry>
 <201202291808.30599.danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: "Danny Kukawka" <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201202291808.30599.danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-02-29 at 18:08 +0100, Danny Kukawka wrote:

> Do you mean something like this: 
> 
> int eth_validate_addr(struct net_device *dev, void *addr)
> {
>  u8 *vaddr;
> 
>  if (addr)
>     vaddr = ((struct sockaddr *) addr)->sa_data;
>  else
>     vaddr = dev->dev_addr;
> 
>  if (!is_valid_ether_addr(vaddr))
>     return -EADDRNOTAVAIL;
> 
>  return 0;
> }
> 
Exactly :)
