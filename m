From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 12:44:58 +0530
Message-ID: <OFD5FAC857.54E87E8A-ON652572D8.0027B47D-652572D8.0027D2D9@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Krishna Kumar2 <krkumar2@in.ibm.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Rick Jones <rick.jones2@hp.com>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp05.au.ibm.com ([202.81.18.154]:51619 "EHLO
	ausmtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754183AbXEKHYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 03:24:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(Mistaken didn't reply-all previous time)

Hi Dave,

David Stevens <dlstevens@us.ibm.com> wrote on 05/11/2007 02:57:56 AM:

> The word "small" is coming up a lot in this discussion, and
> I think packet size really has nothing to do with it. Multiple
> streams generating packets of any size would benefit; the
> key ingredient is a queue length greater than 1.

Correct. Re-thinking about this - for larger packets the bandwidth
may not improve as it reaches line-speed, but I guess CPU util could
reduce (which could reduce in small packet case too). Using "small"
was not covering this case.

Thanks,

- KK

> I think the intent is to remove queue lock cycles by taking
> the whole list (at least up to the count of free ring buffers)
> when the queue is greater than one packet, thus effectively
> removing the lock expense for n-1 packets.


