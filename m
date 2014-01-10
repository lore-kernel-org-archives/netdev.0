From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 ] PIE: Proportional Integral controller
 Enhanced
Date: Thu, 9 Jan 2014 22:52:17 -0800
Message-ID: <20140109225217.3269b74a@nehalam.linuxnetplumber.net>
References: <1389160839-31060-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	Mythili Prabhu <mysuryan@cisco.com>,
	Dave Taht <dave.taht@bufferbloat.net>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:45465 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbaAJGwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 01:52:20 -0500
Received: by mail-pb0-f42.google.com with SMTP id uo5so4060026pbc.15
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 22:52:20 -0800 (PST)
In-Reply-To: <1389160839-31060-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  7 Jan 2014 22:00:39 -0800
Vijay Subramanian <subramanian.vijay@gmail.com> wrote:

> From: Vijay Subramanian <vijaynsu@cisco.com>
> 
> Proportional Integral controller Enhanced (PIE) is a scheduler to address the
> bufferbloat problem.
> 
> We present here a lightweight design, PIE(Proportional Integral controller
> Enhanced) that can effectively control the average queueing latency to a target
> value. Simulation results, theoretical analysis and Linux testbed results have
> shown that PIE can ensure low latency and achieve high link utilization under
> various congestion situations. The design does not require per-packet
> timestamp, so it incurs very small overhead and is simple enough to implement
> in both hardware and software.  "
> 
> For more information, please see technical paper about PIE in the IEEE
> Conference on High Performance Switching and Routing 2013. A copy of the paper
> can be found at ftp://ftpeng.cisco.com/pie/.
> 
> Please also refer to the IETF draft submission at
> http://tools.ietf.org/html/draft-pan-tsvwg-pie-00
> 
> All relevant code, documents and test scripts and results can be found at
> ftp://ftpeng.cisco.com/pie/.
> 
> For problems with the iproute2/tc or Linux kernel code, please contact Vijay
> Subramanian (vijaynsu@cisco.com or subramanian.vijay@gmail.com) Mythili Prabhu
> (mysuryan@cisco.com)
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> Signed-off-by: Mythili Prabhu <mysuryan@cisco.com>
> CC: Dave Taht <dave.taht@bufferbloat.net>

On the net-next-3.13 branch to be held until next merge window
