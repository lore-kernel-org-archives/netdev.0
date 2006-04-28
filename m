From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 12:14:45 -0700 (PDT)
Message-ID: <20060428.121445.81971612.davem@davemloft.net>
References: <54AD0F12E08D1541B826BE97C98F99F143B0F3@NT-SJCA-0751.brcm.ad.broadcom.com>
	<20060428172536.GA16916@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: caitlinb@broadcom.com, kelly@au1.ibm.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:63683
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751443AbWD1TQE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 15:16:04 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060428172536.GA16916@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Fri, 28 Apr 2006 21:25:36 +0400

> The more complex userspace interface we create the less users it will
> have. It is completely unconvenient to read 100 bytes and receive only
> 80, since 20 were eaten by header.

These bytes are charged to socket anyways, and allowing the
headers to be there is the only clean way to finesse the whole
zero-copy problem.

User can manage his data any way he likes.  He can decide to take
advantage of the zero-copy layout we've provided, or he can copy
to put things into a format he is more happy with at the cost
of the copy.
