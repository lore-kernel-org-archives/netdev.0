From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: intel 82599 multi-port performance
Date: Mon, 26 Sep 2011 08:20:49 -0600
Message-ID: <4E808A41.8040902@genband.com>
References: <4E805359.2080600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "J.Hwan Kim" <frog1120@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og126.obsmtp.com ([64.18.2.206]:59799 "EHLO
	exprod7og126.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506Ab1IZOVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 10:21:10 -0400
In-Reply-To: <4E805359.2080600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2011 04:26 AM, J.Hwan Kim wrote:
> Hi, everyone
>
> Now, I'm testing a network card including intel 82599.
> In our experiment, with the driver modified with ixgbe and multi-port
> enabled,

What do you mean by "modified with ixgbe and multi-port enabled"?  You 
shouldn't need to do anything special to use both ports.

> rx performance of each port with 10Gbps of 64bytes frame is
> a half than when only 1 port is used.

Sounds like a cpu limitation.  What is your cpu usage?  How are your 
interrupts routed?  Are you using multiple rx queues?

Chris


-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
