From: Gagan Arneja <gaagaan@gmail.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 13:40:22 -0700
Message-ID: <46438336.5070408@gmail.com>
References: <46435412.50800@hp.com> <1178820423.17393.3.camel@w-sridhar2.beaverton.ibm.com> <464375F9.1050600@gmail.com> <20070510.133710.15264671.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, rick.jones2@hp.com, krkumar2@in.ibm.com,
	johnpol@2ka.mipt.ru, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.113.40.141]:43935 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755354AbXEJUkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 16:40:24 -0400
In-Reply-To: <20070510.133710.15264671.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> 
> If the qdisc is packed with packets and we would just loop sending
> them to the device, yes it might make sense.
> 
> But if that isn't the case, which frankly is the usual case, you add a
> non-trivial amount of latency by batching and that's bad exactly for
> the kind of applications that send small frames.
> 

I don't understand how transmitting already batched up packets in one go 
introduce latency.

--
Gagan
