From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 0/10] enic: updates to version 1.4.1.1
Date: Fri, 25 Jun 2010 21:06:34 -0700 (PDT)
Message-ID: <20100625.210634.52176209.davem@davemloft.net>
References: <20100624204723.22595.42990.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, scofeldm@cisco.com, roprabhu@cisco.com
To: vkolluri@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38361
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750758Ab0FZEGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jun 2010 00:06:22 -0400
In-Reply-To: <20100624204723.22595.42990.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>
Date: Thu, 24 Jun 2010 13:49:10 -0700

> The following patch series implements enic driver updates:
> 
> 01/10 - Feature Add: Replace LRO with GRO
> 02/10 - Bug Fix: Change hardware ingress vlan rewrite mode
> 03/10 - Use a lighter reset operation for enic devices
> 04/10 - Clean up: Add wrapper routines for firmware devcmd calls
> 05/10 - Use (netdev|dev|pr)_<level> macro helpers for logging
> 06/10 - Add new firmware devcmds
> 07/10 - Use receive queue buffer blocks of 32/64 entries
> 08/10 - Feature Add: Add loopback capability to enic devices
> 09/10 - Bug Fix: Handle surprise hardware removals
> 10/10 - Clean ups

All applied, without the "slab.h" include removals so it still
builds.
