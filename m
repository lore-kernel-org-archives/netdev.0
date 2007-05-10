From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 14:53:42 -0700
Message-ID: <OFA468C4CC.DFCC28AE-ON882572D7.0077B6D5-882572D7.00783CAB@us.ibm.com>
References: <4643926D.5020108@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Krishna Kumar2 <krkumar2@in.ibm.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:45675 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755263AbXEJVxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 17:53:51 -0400
In-Reply-To: <4643926D.5020108@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Which worked _very_ well (the whole list) going in the other direction 
for the 
> netisr queue(s) in HP-UX 10.20.  OK, I promise no more old HP-UX stories 
for the 
> balance of the week :)

        Yes, OSes I worked on in other lives usually took the whole queue
and then took responsibility for handling them outside the lock.
        A dequeue_n() under 1 lock should still be better than n locks,
I'd think, since you may bounce to different CPUs during the n individual
cycles.

                                                        +-DLS

