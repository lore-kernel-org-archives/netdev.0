From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] Bound TSO defer time (resend)
Date: Tue, 17 Oct 2006 00:18:33 -0400
Message-ID: <45345999.4000300@psc.edu>
References: <Pine.LNX.4.58.0610162051170.12462@dexter.psc.edu> <20061016202035.6d55b96e@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:55008 "EHLO mailer2.psc.edu")
	by vger.kernel.org with ESMTP id S1161139AbWJQESm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 00:18:42 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061016202035.6d55b96e@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Mon, 16 Oct 2006 20:53:20 -0400 (EDT)
> John Heffner <jheffner@psc.edu> wrote:

>> This patch limits the amount of time you will defer sending a TSO segment
>> to less than two clock ticks, or the time between two acks, whichever is
>> longer.

> 
> Okay, but doing any timing on clock ticks makes the behavior dependent
> on the value of HZ which doesn't seem desirable. Should this be based
> on RTT or a real-time values?

It would be nice to use a high res clock so you don't depend on HZ, but 
this is still expensive on most SMP arch's as I understand it.

   -John

