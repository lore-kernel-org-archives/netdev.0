From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: Linux 2.6.22: Leak r=1 1
Date: Wed, 11 Jul 2007 15:01:32 -0400
Message-ID: <4695290C.1040303@redhat.com>
References: <20070711174030.tjmxpxtfsn4twgk2@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Networking Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42804 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761976AbXGKTBe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2007 15:01:34 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l6BJ1X7H015835
	for <netdev@vger.kernel.org>; Wed, 11 Jul 2007 15:01:33 -0400
Received: from mail.boston.redhat.com (mail.boston.redhat.com [172.16.76.12])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l6BJ1Xla022566
	for <netdev@vger.kernel.org>; Wed, 11 Jul 2007 15:01:33 -0400
Received: from [172.16.83.145] (dhcp83-145.boston.redhat.com [172.16.83.145])
	by mail.boston.redhat.com (8.13.1/8.13.1) with ESMTP id l6BJ1XG2026934
	for <netdev@vger.kernel.org>; Wed, 11 Jul 2007 15:01:33 -0400
In-Reply-To: <20070711174030.tjmxpxtfsn4twgk2@m.safari.iki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/11/2007 01:40 PM, Sami Farin wrote:
> That's right, so descriptive is the new Linux kernel 2.6.22.
> Took a while to grep what is "leaking".
> 

You didn't post that:

$ find . -type f | xargs grep "Leak r=" /dev/null
./net/ipv4/tcp_input.c:                 printk(KERN_DEBUG "Leak r=%u %d\n",

