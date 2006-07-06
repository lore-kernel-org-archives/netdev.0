From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: SKB BUG: Invalid truesize
Date: Thu, 06 Jul 2006 11:12:52 -0700
Message-ID: <44AD52A4.5030704@intel.com>
References: <BB1F4EFD574E9F409035BDA71C9612500242B8@exchange.i-bn>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:14935 "EHLO
	azsmga101-1.ch.intel.com") by vger.kernel.org with ESMTP
	id S1750716AbWGFSZD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jul 2006 14:25:03 -0400
To: Beschorner Daniel <Daniel.Beschorner@facton.com>
In-Reply-To: <BB1F4EFD574E9F409035BDA71C9612500242B8@exchange.i-bn>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Beschorner Daniel wrote:
> Does it harm?
> 
> SKB BUG: Invalid truesize (380) len=1383, sizeof(sk_buff)=156
> SKB BUG: Invalid truesize (316) len=1383, sizeof(sk_buff)=156
> SKB BUG: Invalid truesize (348) len=1383, sizeof(sk_buff)=156
> SKB BUG: Invalid truesize (316) len=1383, sizeof(sk_buff)=156
> SKB BUG: Invalid truesize (380) len=1383, sizeof(sk_buff)=156
> 
> I found it in the log of a 2.6.17 box using IPSEC tunnels.

it does harm, we need to know which network driver(s) are/were loaded when 
this happened, for starters.

cheers,

Auke
