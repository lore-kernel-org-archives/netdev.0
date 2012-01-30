From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH V2] net/sched: =?UTF-8?Q?sch=5Fplug=20-=20Queue=20traf?=  =?UTF-8?Q?fic=20until=20an=20explicit=20release=20command?=
Date: Mon, 30 Jan 2012 15:54:52 +0100
Message-ID: <313929ea4dca3c8fd6948797e03121a8@localhost>
References: <1327823619-29274-1-git-send-email-rshriram@cs.ubc.ca>
 <1327934756.2243.3.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Shriram Rajagopalan <rshriram@cs.ubc.ca>, <netdev@vger.kernel.org>,
	Brendan Cully <brendan@cs.ubc.ca>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:47147 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751742Ab2A3Oyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 09:54:53 -0500
In-Reply-To: <1327934756.2243.3.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 30 Jan 2012 09:45:56 -0500, Jamal Hadi Salim wrote:



> Please address the comment from Hagen on the printk (kill it).

> Other than that i think this simple enough and non-intrusive

> to other users that you can add an Acked-by from me.

> It will be nice to get it to be generic as per Hagen's and my

> earlier comments.



I thought about sch_plug a second time and I like the idea of a user-space

based flow-controlled queue. But as I wrote in my first email: the current

implementation is a little bit XEN specific. Make it more general

(plug/unplug, plug/packet-based-unplug) and it is a great contribution.



Hagen
