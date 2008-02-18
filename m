From: Patrick McHardy <kaber@trash.net>
Subject: Re: [2.6 patch] remove include/linux/netfilter_ipv4/ipt_SAME.h
Date: Mon, 18 Feb 2008 16:10:48 +0100
Message-ID: <47B99FF8.8030900@trash.net>
References: <20080217083031.GY3848@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:32196 "EHLO
	viefep33-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752793AbYBRPLH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 10:11:07 -0500
In-Reply-To: <20080217083031.GY3848@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> This patch removes the no longer used include/linux/netfilter_ipv4/ipt_SAME.h


We kept it around because old iptables binaries need it to build.
The kernel no longer supports it, but people might still wish to
use a distributor-built iptables binary with old kernels. It will
be removed with a number of other headers kept for compatibility
in 1-2 years.

