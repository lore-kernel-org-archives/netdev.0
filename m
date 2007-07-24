From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH 2/4] Add new timeval_to_sec function
Date: Tue, 24 Jul 2007 12:54:06 -0700
Message-ID: <OFCF3FE381.59E49EB2-ON88257322.006D210A-88257322.006D3EC1@us.ibm.com>
References: <46A59AAF.6090605@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	sri@linux.vnet.ibm.com, Thomas Gleixner <tglx@linutronix.de>,
	Varun Chandramohan <varunc@linux.vnet.ibm.com>,
	varuncha@in.ibm.com
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:54633 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbXGXTyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 15:54:11 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l6OImEUp019437
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 14:48:14 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6OJsAPD268072
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 13:54:10 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6OJs9UG024126
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 13:54:10 -0600
In-Reply-To: <46A59AAF.6090605@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Hartkopp <socketcan@hartkopp.net> wrote on 07/23/2007 11:22:39 PM:

> When you like to create any timeout based on your calculated value, you
> might run into the problem that your calculated value is set to _zero_
> even if there was "some time" before the conversion. This might probably
> not what you indented to get.

        BTW, these are stats (for human consumption), not timers.

                                                        +-DLS

