From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: add DiffServ priority based routing
Date: Thu, 11 Mar 2010 11:29:41 -0800 (PST)
Message-ID: <20100311.112941.177105216.davem@davemloft.net>
References: <4B4CE2B8.1040702@redfish-solutions.com>
	<20100112.130355.144803575.davem@davemloft.net>
	<4B9943A4.8040606@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torsten.schmidt@s2006.tu-chemnitz.de, netdev@vger.kernel.org
To: philipp_subx@redfish-solutions.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51844
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754729Ab0CKT3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 14:29:21 -0500
In-Reply-To: <4B9943A4.8040606@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
Date: Thu, 11 Mar 2010 12:25:24 -0700

> I agree with the notion that certain values should be set side-wide
> (or at least system-wide) to prevent malicious users from exploiting
> QoS...  that's why I've been advocating for QoS settings to be
> specified in a system configuration file, and not a per-user
> configuration file.

So I can set whatever I want on my personal workation.

I'm sure sysadmins will be happy about that.

Look, this doesn't work.  QoS handling and policy belongs in the
egress point to the network, it's the only way to control this
properly and prevent abuse.
