From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 7/9] sky2: skb recycling
Date: Thu, 18 Jun 2009 14:22:04 -0700
Message-ID: <20090618142204.29f29fda@nehalam>
References: <20090617173031.703636683@vyatta.com>
	<20090617173140.244124173@vyatta.com>
	<alpine.WNT.2.00.0906181411470.6076@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43774 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753905AbZFRVWH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jun 2009 17:22:07 -0400
In-Reply-To: <alpine.WNT.2.00.0906181411470.6076@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Jun 2009 14:13:20 -0700 (Pacific Daylight Time)
"Brandeburg, Jesse" <jesse.brandeburg@intel.com> wrote:

> 
> 
> On Wed, 17 Jun 2009, Stephen Hemminger wrote:
> 
> > This patch implements skb recycling. It reclaims transmitted skb's
> > for use in the receive ring.
> 
> Was sky2 able to show any gain in forwarding performance due to this 
> patch?  Was it significant?  What kind of machine was used to test?

no not really, sky2 has other issue which hurt performance.


-- 
