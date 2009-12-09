From: Jon Loeliger <jdl@bigfootnetworks.com>
Subject: Re: Using netlink for intra-kernel requests?
Date: Wed, 09 Dec 2009 10:41:40 -0600
Message-ID: <1260376900.31877.10.camel@jdl-desktop>
References: <1260308546.29528.27.camel@jdl-desktop>
	 <87bpi8mfur.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from L01SLCSMTP01.calltower.com ([69.4.184.248]:15466 "EHLO
	L01SLCSMTP01.calltower.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756051AbZLIQnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 11:43:04 -0500
In-Reply-To: <87bpi8mfur.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-12-09 at 14:33 +0100, Andi Kleen wrote:
> Jon Loeliger <jdl@bigfootnetworks.com> writes:
> > I feel like I am missing or don't know where to find the
> > documentation for the intra-kernel netlink messaging.
> 
> I don't think the kernel uses intra kernel netlink normally,
> just tends to call functions directly. That's more efficient
> anyways.
> 
> -Andi

Hi Andi,

OK.  So, _which_ set of netlink functions should I use?
Is rtnl_notify() the correct one to use to send a netlink
request for the RTM_GETQDISC or RTM_GETTCCLASS data?

What's the mechanism used to send and then receive a reply?
Will it be async?  How do I specify the call-back to receive
the reply netlink message?  Or will it be synchronous and
I pass in some call-back-reply function?

Thanks for you suggestions!
jdl


