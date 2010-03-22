From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net_sched: make traffic control network namespace aware
Date: Mon, 22 Mar 2010 18:56:02 +0100
Message-ID: <4BA7AF32.8020001@trash.net>
References: <20100320014013.GC13239@boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tom Goff <thomas.goff@boeing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40175 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755517Ab0CVR4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 13:56:04 -0400
In-Reply-To: <20100320014013.GC13239@boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Goff wrote:
> Mostly minor changes to add a net argument to various functions and
> remove initial network namespace checks.
> 
> Make /proc/net/psched per network namespace.

Looks fine from a qdisc POV. One thing that appears to be missing
though is teql master netdev registration in other than the initial
namespace.
