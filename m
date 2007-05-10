From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 13:32:16 -0700 (PDT)
Message-ID: <20070510.133216.95506791.davem@davemloft.net>
References: <4643654F.5060207@hp.com>
	<5640c7e00705101159w68750a47xc06495e4395de583@mail.gmail.com>
	<464370BA.3020907@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.mcdonald@jandi.co.nz, rick.jones2@hp.com, krkumar2@in.ibm.com,
	johnpol@2ka.mipt.ru, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39111
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755016AbXEJUcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 16:32:13 -0400
In-Reply-To: <464370BA.3020907@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Thu, 10 May 2007 15:21:30 -0400

> The win might be biggest on a system were a lot of applications send
> a lot of small packets.  Some number will aggregate in the prio
> queue and then get shoved into a driver in one go.
>
> But...  this is all conjecture until we see the code.

Also, whatever you gain in cpu usage you'll lose in latency.

And things sending tiny frames are exactly the ones that care about
latency.
