From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/20] Batch network namespace cleanup
Date: Mon, 30 Nov 2009 07:44:03 -0500
Message-ID: <1259585043.873.21.camel@bigi>
References: <m1ljhodbtw.fsf@fess.ebiederm.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:7391 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515AbZK3MoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 07:44:00 -0500
Received: by qw-out-2122.google.com with SMTP id 3so683077qwe.37
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2009 04:44:06 -0800 (PST)
In-Reply-To: <m1ljhodbtw.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-11-29 at 17:46 -0800, Eric W. Biederman wrote:
> 
> Recently Jamal and Daniel perform some experiments and found that
> large numbers of network namespace exiting simultaneously is very
> inefficient.  24+ minutes in some configurations.  The cpu overhead
> was negligible but it results in long hold times of net_mutex, and
> memory being consumed a long time after the last user has gone away.
> 
> I looked into it and discovered that by batching network namespace
> cleanups I can reduce the time for 4k network namespaces exiting from
> 5-7 minutes in my configuration to 44 seconds.

Excellent work Eric. I have time today so i can test these patches
status quo vs.
This is against net-next?

cheers,
jamal



