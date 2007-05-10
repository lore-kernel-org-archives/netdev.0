From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 14:27:56 -0700
Message-ID: <OF5ECC8062.FEB97ADC-ON882572D7.0075648E-882572D7.0075E0A6@us.ibm.com>
References: <46435412.50800@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Krishna Kumar2 <krkumar2@in.ibm.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:34086 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754409AbXEJV2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 17:28:04 -0400
In-Reply-To: <46435412.50800@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The word "small" is coming up a lot in this discussion, and
I think packet size really has nothing to do with it. Multiple
streams generating packets of any size would benefit; the
key ingredient is a queue length greater than 1.

I think the intent is to remove queue lock cycles by taking
the whole list (at least up to the count of free ring buffers)
when the queue is greater than one packet, thus effectively
removing the lock expense for n-1 packets.

                                        +-DLS

