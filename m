From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Wake On Lan device semantics
Date: Fri, 3 Nov 2006 15:48:20 -0800
Message-ID: <20061103154820.37f05a13@freekitty>
References: <20061103152025.5d27bd8d@freekitty>
	<454BD44D.2060005@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:19421 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932498AbWKCXtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Nov 2006 18:49:33 -0500
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <454BD44D.2060005@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 03 Nov 2006 15:44:13 -0800
Auke Kok <auke-jan.h.kok@intel.com> wrote:

> Stephen Hemminger wrote:
> > It doesn't seem like a good idea for a network device to wake the system
> > if it is down.
> 
> before suspend existed this was the only useful case for WoL. Why does it not seem a 
> good idea to wake up a machine that was shutdown (and thus the interface `downed`) ?
> 
> Auke

It seems odd because that means you can never make a device fully deaf.

-- 
Stephen Hemminger <shemminger@osdl.org>
