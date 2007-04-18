From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC][PATCH -mm take4 2/6] support multiple logging
Date: Wed, 18 Apr 2007 07:40:27 -0700
Message-ID: <20070418074027.48375647@localhost.localdomain>
References: <462605DC.2080804@bx.jp.nec.com>
	<462609D1.50300@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Keiichi KII <k-keiichi@bx.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34081 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992680AbXDROpq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Apr 2007 10:45:46 -0400
In-Reply-To: <462609D1.50300@bx.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Apr 2007 21:06:41 +0900
Keiichi KII <k-keiichi@bx.jp.nec.com> wrote:

> From: Keiichi KII <k-keiichi@bx.jp.nec.com>
> 
> This patch contains the following changes for supporting multiple logging
>  agents.
> 
> 1. extend netconsole to multiple netpolls
>    To send kernel messages to multiple logging agents, extend netcosnole
>     to be able to use multiple netpolls. Each netpoll sends kernel messages
>     to its own logging agent.
> 
> 2. change config parameter format
>    We change config parameter format from single configuration to multiple 
>    configurations separated by ';'.
> 
>    ex) sending kernel messages to destination1 and destination2 using eth0.
>     modprobe netconsole \
>             netconsole="@/eth0,@[destination1]/;@/eth0,@[destination2]/"

Please include an update to Documentation/networking/netconsole.txt
