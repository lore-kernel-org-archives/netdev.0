From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [patch] Performance enhancement patches for SB1250 MAC
Date: Thu, 12 Oct 2006 15:13:56 -0700
Message-ID: <20061012151356.4a3a4096@freekitty>
References: <D9055C0A0A86BD4E89AD96A89EA767DBA6AEBE@ALA-MAIL03.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:49613 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751184AbWJLWN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2006 18:13:59 -0400
To: "Yang, Steve" <steve.yang@windriver.com>
In-Reply-To: <D9055C0A0A86BD4E89AD96A89EA767DBA6AEBE@ALA-MAIL03.corp.ad.wrs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Oct 2006 14:54:33 -0700
"Yang, Steve" <steve.yang@windriver.com> wrote:

> FYI ...
> 
> Regards, 
> Steve Yang
> 
> -----Original Message-----
> From: Yang, Steve 
> Sent: Monday, September 25, 2006 3:50 PM
> To: 'linux-mips@linux-mips.org'
> Cc: 'ralf@linux-mips.org'; 'Mark E Mason'
> Subject: Performance enhancement patches for SB1250 MAC
> 
> Hi,
> 
> The attached are two network performance enhancement patches for SB1250
> MAC. The NAPI patch applies first. Followed by the "skb cache" patch.
> They applied and builds cleanly on 2.6.18 kernel for the following
> kernel option combinations:
> 
> SBMAC_NAPI	no	yes	yes
> SKB_CACHE	no	no	yes
>  
> Regards,
> Steve Yang
> 

NAK on the SKB_CACHE it is idea that just ends up favoring your
driver at the expense of the rest of the system. Also, there are
resource/memory starvation issues and probably other races as well.

I bet it makes your benchmark run faster, but it doesn't belong in
normal kernel

-- 
Stephen Hemminger <shemminger@osdl.org>
