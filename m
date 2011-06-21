From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Steps to integrate new 40G Network driver to the kernel tree
Date: Tue, 21 Jun 2011 16:52:36 -0700
Message-ID: <20110621165236.33ae4149@nehalam.ftrdhcpuser.net>
References: <4DA8D9F6.2070908@oracle.com>
	<20110415175429.5e91fb59@nehalam>
	<4E012D80.4090907@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joyce Yu - System Software <joyce.yu@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43805 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756933Ab1FUXwm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2011 19:52:42 -0400
In-Reply-To: <4E012D80.4090907@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Jun 2011 16:47:12 -0700
Joyce Yu - System Software <joyce.yu@oracle.com> wrote:

> 
> Since it is a new driver, shall I follow the "Submitting Drivers for the 
> Linux Kernel" Doc? The driver is ready and passed all our QA cycles. I  
> have three source base, one is for 2.6.16 and 2.6.18 (for RHL 5.X and 
> SLES 10 SP3) , one is for 2.6.32 (For RHL 6.X, SLES11SP1), one for 
> 2.6.27 (For SLES11). Can it be integrated to the 2.6.18 and 2.6.32 tree? 
> or it has to be in the latest 2.6.39 or later?
> 

Do you want the driver to show up in 3.0 (aka 2.6.40) or next release.
For 3.0 submit patch against 3.0-rc4 for next release base the patch
against the network development tree (net-next-2.6).

The code should remove all special case code to deal with old kernel
versions. No backward compatiablity #ifdef's

