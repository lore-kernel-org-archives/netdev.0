From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] allow ip_tables.h to be used from userspace
Date: Tue, 05 Dec 2006 19:52:54 +0100
Message-ID: <4575C006.7060204@trash.net>
References: <20061205102927.4f1ef22f@freekitty>	<4575BC9D.8070900@trash.net> <20061205104622.7b86182e@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43603 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968627AbWLESxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 13:53:00 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061205104622.7b86182e@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Tue, 05 Dec 2006 19:38:21 +0100
> Patrick McHardy <kaber@trash.net> wrote:
> 
> 
>>I think this regex should be fixed instead to get rid of it
>>while sanitizing (Makefile.headersinst).
>
> 
> But ip_tables.h should still put include of compiler.h inside #ifdef __KERNEL__

Actually that should also get stripped away by the regex.
