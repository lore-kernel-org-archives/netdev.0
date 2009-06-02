From: Patrick McHardy <kaber@trash.net>
Subject: Re: relationship between ingress policer and netfilter hooks?
Date: Tue, 02 Jun 2009 19:04:44 +0200
Message-ID: <4A255BAC.8070406@trash.net>
References: <4A25457F.2070000@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44047 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752815AbZFBREn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 13:04:43 -0400
In-Reply-To: <4A25457F.2070000@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen wrote:
> Hi all,
> 
> Can someone tell me where the hook is for incoming packets to be sent
> through the ingress policer?
> 
> In particular, I'm trying to find out how the ingress traffic shaping
> hook relates to the various netfilter hooks so that I can set them up to
> behave nicely together.

They're not related at all. The ingress qdisc is hooked at
net/dev/core.c:handle_ing().
