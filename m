From: Philip Craig <philipc@snapgear.com>
Subject: Re: [RFC] gre: transparent ethernet bridging
Date: Thu, 03 Aug 2006 11:08:43 +1000
Message-ID: <44D14C9B.2030706@snapgear.com>
References: <44CDD631.5030008@snapgear.com>	<20060731091423.3327f85e@dxpl.pdx.osdl.net>	<44CEAB31.5090501@snapgear.com>	<20060731220822.444f04e4@localhost.localdomain>	<44CF1EF8.2090800@snapgear.com>	<44D04386.2040705@snapgear.com> <20060802102337.7ba32020@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:42967 "EHLO
	cyberguard.com.au") by vger.kernel.org with ESMTP id S932085AbWHCBIr
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 21:08:47 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060802102337.7ba32020@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Wed, 02 Aug 2006 16:17:42 +1000
> Philip Craig <philipc@snapgear.com> wrote:
>> It generates a random mac address for gre ports, and also stores
>> a copy of the mac address for ethernet ports, rather than checking
>> dev->type everywhere.
>
> That looks cleaner. I wonder if using a fixed OUI would be better
> than random addresses but then choosing an OUI would be a problem.

random_ether_addr() sets the local assignment bit. This is what
various other virtual devices do (including tap devices, which can
also be bridged).

> You probably should add a comment about what this function is doing,
> and why.

Okay.

