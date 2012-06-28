From: Rick Jones <rick.jones2@hp.com>
Subject: Re: RFC: replace packets already in queue
Date: Thu, 28 Jun 2012 09:24:46 -0700
Message-ID: <4FEC854E.8080603@hp.com>
References: <FB112703C4930F4ABEBB5B763F96491139378722@MAILSERV2A.lorien.fkie.fgan.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Erdt, Ralph" <ralph.erdt@fkie.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:35479 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843Ab2F1QYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 12:24:47 -0400
In-Reply-To: <FB112703C4930F4ABEBB5B763F96491139378722@MAILSERV2A.lorien.fkie.fgan.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You might want to try the recent "codel" additions to the stack.  They 
seek to keep the size of queues more manageable while still allowing the 
occasional burst.

rick jones
