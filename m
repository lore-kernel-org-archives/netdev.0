From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC, PATCH 2.6.29.2] Ethernet V2.0 Configuration Testing
 Protocol, revision 20090428
Date: Tue, 28 Apr 2009 16:15:45 -0700
Message-ID: <20090428161545.0612476d@nehalam>
References: <20090428220143.31395c24.lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mark Smith
	<lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33029 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754825AbZD1XPv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2009 19:15:51 -0400
In-Reply-To: <20090428220143.31395c24.lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Apr 2009 22:01:43 +0930
Mark Smith  <lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org> wrote:

> Hi,
> 
> Following on from my initial ECTP post on the 23rd of April, here is an
> updated revision.
> 
> Changes:
> 
> o  The ectpping utility is now available at http://ectpping.berlios.de.
> Kconfig and Documentation/networking/ectp.txt updated to reflect it's
> availability and location
> 
> o  absolutely avoid an unlikely unsigned int msgs_len wrap around in
> ectp_linear_skb_ok() and ectp_nonlinear_skb_ok()
> 
> o  use skb_queue_is_first() instead of skb_peek() in
> ectp_queue_delayed_tx_skb()
> 
> Patch below is against 2.6.29.2
> 
> Feedback from some networking and sys admin people I've told about it
> has been positive - they all agree with the benefit of being able to
> perform "ping" style testing on an Ethernet segment without requiring
> IP to be configured.
> 
> Any suggestions for improvement would be most appreciated.
> 
> Thanks very much,
> Mark.
> 

Why does this have to be in the kernel?  Why not all in user space
with AF_PACKET?
