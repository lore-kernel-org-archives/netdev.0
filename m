From: David Miller <davem@davemloft.net>
Subject: Re: RFC: on [ab]use of skb->cb by VLAN code
Date: Mon, 30 Jul 2007 22:18:47 -0700 (PDT)
Message-ID: <20070730.221847.74747100.davem@davemloft.net>
References: <1185847324.5162.31.camel@localhost>
	<20070730.190621.13770511.davem@davemloft.net>
	<46AEBADB.7030007@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, kaber@trash.net, netdev@vger.kernel.org,
	mcarlson@broadcom.com
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36645
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758149AbXGaFSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 01:18:48 -0400
In-Reply-To: <46AEBADB.7030007@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Mon, 30 Jul 2007 21:30:19 -0700

> So, shall we add a new field to the skb in order to get the info out of cb?
> 
> Looks like a single 32-bit field would be sufficient.

I'm trying to brainstorm how to avoid consuming new space in
sk_buff and I'd like others to do so as well.

This isn't super urgent at all so I'll just think about it
on the backburner, things like the NAPI changes and dealing
with all of today's networking bug fixes is my top priority
at the moment.
