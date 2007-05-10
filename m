From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 14:45:17 -0700
Message-ID: <4643926D.5020108@hp.com>
References: <OF5ECC8062.FEB97ADC-ON882572D7.0075648E-882572D7.0075E0A6@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Krishna Kumar2 <krkumar2@in.ibm.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:52205 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756931AbXEJVpW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 17:45:22 -0400
In-Reply-To: <OF5ECC8062.FEB97ADC-ON882572D7.0075648E-882572D7.0075E0A6@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Stevens wrote:
> The word "small" is coming up a lot in this discussion, and
> I think packet size really has nothing to do with it. Multiple
> streams generating packets of any size would benefit; the
> key ingredient is a queue length greater than 1.
> 
> I think the intent is to remove queue lock cycles by taking
> the whole list (at least up to the count of free ring buffers)
> when the queue is greater than one packet, thus effectively
> removing the lock expense for n-1 packets.

Which worked _very_ well (the whole list) going in the other direction for the 
netisr queue(s) in HP-UX 10.20.  OK, I promise no more old HP-UX stories for the 
balance of the week :)

Taking some count of the list might be a triffle too complicated.

rick jones
