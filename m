From: David Miller <davem@davemloft.net>
Subject: Re: RFC: issues concerning the next NAPI interface
Date: Fri, 24 Aug 2007 14:44:36 -0700 (PDT)
Message-ID: <20070824.144436.59664160.davem@davemloft.net>
References: <20070824085203.42f4305c@freepuppy.rosehill.hemminger.net>
	<OF0002C3DB.2E4C4A38-ON88257341.005B1253-88257341.005C7C2A@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, akepner@sgi.com,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	meder@de.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, ossthema@de.ibm.com,
	raisch@de.ibm.com, stefan.roscher@de.ibm.com, themann@de.ibm.com,
	tklein@de.ibm.com
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40831
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757261AbXHXVok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 17:44:40 -0400
In-Reply-To: <OF0002C3DB.2E4C4A38-ON88257341.005B1253-88257341.005C7C2A@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Stevens <dlstevens@us.ibm.com>
Date: Fri, 24 Aug 2007 09:50:58 -0700

>         Problem is if it increases rapidly, you may drop packets
> before you notice that the ring is full in the current estimated
> interval.

This is one of many reasons why hardware interrupt mitigation
is really needed for this.
