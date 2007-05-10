From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 19:08:33 +0400
Message-ID: <20070510150833.GB24898@2ka.mipt.ru>
References: <20070510145351.1390.77066.sendpatchset@K50wks273871wss.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:46600 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752314AbXEJPJH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 11:09:07 -0400
Content-Disposition: inline
In-Reply-To: <20070510145351.1390.77066.sendpatchset@K50wks273871wss.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 10, 2007 at 08:23:51PM +0530, Krishna Kumar (krkumar2@in.ibm.com) wrote:
> The reason to implement the same was to speed up IPoIB driver. But
> before doing that, a proof of concept for E1000/AMSO drivers was
> considered (as most of the code is generic) before implementing for
> IPoIB. I do not have test results at this time but I am working on it.
> 
> Please let me know if this approach is acceptable, or any suggestions.

Doesn't it looks exactly like GSO/TSO/LRO stuff implemented already?

Btw, main CPU limiting factor here is syscall overhead (userspace protocol
processing with 1500 MTU allows to reduce CPU usage and increase
performance for 128 bytes packets sending/receiving total of 10 times).

> Thanks,
> 
> - KK

-- 
	Evgeniy Polyakov
