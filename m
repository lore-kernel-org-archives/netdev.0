From: David Miller <davem@davemloft.net>
Subject: Re: unloading the ipv6 module
Date: Thu, 26 Feb 2009 05:51:38 -0800 (PST)
Message-ID: <20090226.055138.178968734.davem@davemloft.net>
References: <49A69784.6070204@free.fr>
	<20090226.052411.77955912.davem@davemloft.net>
	<49A69C66.6000005@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: daniel.lezcano@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48136
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757040AbZBZNv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 08:51:57 -0500
In-Reply-To: <49A69C66.6000005@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <daniel.lezcano@free.fr>
Date: Thu, 26 Feb 2009 14:43:02 +0100

> I was wondering if it would have make sense to remove the unloading
> module code from ipv6 which is big at all and not testable.

The majority of that code is needed anyways for the module load
failure paths.
