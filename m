From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: RFC: issues concerning the next NAPI interface
Date: Fri, 24 Aug 2007 16:51:03 -0500
Message-ID: <20070824215103.GO4282@austin.ibm.com>
References: <20070824085203.42f4305c@freepuppy.rosehill.hemminger.net> <OF0002C3DB.2E4C4A38-ON88257341.005B1253-88257341.005C7C2A@us.ibm.com> <20070824.144436.59664160.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dlstevens@us.ibm.com, tklein@de.ibm.com, themann@de.ibm.com,
	stefan.roscher@de.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, raisch@de.ibm.com,
	netdev-owner@vger.kernel.org, linuxppc-dev@ozlabs.org,
	akepner@sgi.com, meder@de.ibm.com, ossthema@de.ibm.com,
	shemminger@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:37572 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760243AbXHXVvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 17:51:06 -0400
Content-Disposition: inline
In-Reply-To: <20070824.144436.59664160.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 24, 2007 at 02:44:36PM -0700, David Miller wrote:
> From: David Stevens <dlstevens@us.ibm.com>
> Date: Fri, 24 Aug 2007 09:50:58 -0700
> 
> >         Problem is if it increases rapidly, you may drop packets
> > before you notice that the ring is full in the current estimated
> > interval.
> 
> This is one of many reasons why hardware interrupt mitigation
> is really needed for this.

When turning off interrupts, don't turn them *all* off.
Leave the queue-full interrupt always on.

--linas
