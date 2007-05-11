From: Gagan Arneja <gaagaan@gmail.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 22:57:54 -0700
Message-ID: <464405E2.5020409@gmail.com>
References: A<OF3528B24A.B797EFB6-ON652572D8.001F4AB0-652572D8.001F6B22@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sceptre.pobox.com ([207.106.133.20]:37742 "EHLO
	sceptre.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758714AbXEKF5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 01:57:44 -0400
In-Reply-To: <OF3528B24A.B797EFB6-ON652572D8.001F4AB0-652572D8.001F6B22@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> Right, but I am the sole dequeue'r, and on failure, I requeue those packets
> to
> the beginning of the queue (just as it would happen in the regular case of
> one
> packet xmit/failure/requeue).

What about a race between trying to reacquire queue_lock and another 
failed transmit?

--
Gagan

> 
> - KK
> 
