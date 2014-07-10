From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] net: cpmac: fix in debug messages
Date: Thu, 10 Jul 2014 11:18:57 -0700
Message-ID: <1405016337.2796.6.camel@joe-AO725>
References: <1404986378-28555-1-git-send-email-varkabhadram@gmail.com>
	 <53BECE0E.3030209@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: varkabhadram@gmail.com, netdev@vger.kernel.org,
	mugunthanvnm@ti.com, linux@rainbow-software.org, balbi@ti.com,
	george.cherian@ti.com, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0194.hostedemail.com ([216.40.44.194]:56977 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750945AbaGJSTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 14:19:05 -0400
In-Reply-To: <53BECE0E.3030209@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-07-10 at 21:31 +0400, Sergei Shtylyov wrote:
> > When we use pr_debug()/netdev_dbg() new lines are inserting in b/w
> > the values. The format when i use the printk()
> 
>     Please use pr_cont() instead.

Using pr_cont to continue a <foo>_dbg statement is
ineffective.

There really should be a <foo>_dbg_cont mechanism,
but neither normal pr_debug nor dynamic debug support
such a thing.
