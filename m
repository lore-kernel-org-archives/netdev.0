From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: BUG: soft lockup detected on CPU#0!  (2.6.18.2 plus hacks)
Date: Wed, 3 Jan 2007 14:14:58 -0800
Message-ID: <OFD014A990.71736F9E-ON88257258.0079E460-88257258.007A382C@us.ibm.com>
References: <4599E6D5.6050207@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: jarkao2@o2.pl, NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:52712 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932147AbXACWPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 17:15:01 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id l03MF00E022383
	for <netdev@vger.kernel.org>; Wed, 3 Jan 2007 17:15:00 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id l03MExJJ506988
	for <netdev@vger.kernel.org>; Wed, 3 Jan 2007 15:14:59 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l03MExMA027569
	for <netdev@vger.kernel.org>; Wed, 3 Jan 2007 15:14:59 -0700
In-Reply-To: <4599E6D5.6050207@candelatech.com>
To: Ben Greear <greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben & Jarek,
        Your analysis looks correct to me. It seems to me the problem is 
that
we don't want the in_device to be searchable until after the 
initialization is done.
What about moving the initialization of dev->ip_ptr in inetdev_init() to 
after the
"out" label?

                                                        +-DLS

