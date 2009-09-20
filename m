From: jamal <hadi@cyberus.ca>
Subject: Re: [iproute2] tc action mirred    question
Date: Sun, 20 Sep 2009 09:33:27 -0400
Message-ID: <1253453607.16548.11.camel@dogo.mojatatu.com>
References: <404956.88336.qm@web111607.mail.gq1.yahoo.com>
	 <1252376168.5244.11.camel@dogo.mojatatu.com>
	 <313388.35529.qm@web111617.mail.gq1.yahoo.com>
	 <1252534266.4119.5.camel@dogo.mojatatu.com>
	 <204967.7557.qm@web111613.mail.gq1.yahoo.com>
	 <1252671940.25158.5.camel@dogo.mojatatu.com>
	 <510605.34044.qm@web111611.mail.gq1.yahoo.com>
	 <1252704524.25158.42.camel@dogo.mojatatu.com>
	 <833118.87017.qm@web111618.mail.gq1.yahoo.com>
	 <1253104099.4584.9.camel@dogo.mojatatu.com>
	 <908876.76571.qm@web111609.mail.gq1.yahoo.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux netdev <netdev@vger.kernel.org>
To: Xiaofei Wu <xiaofei_wu08@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:12976 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951AbZITNnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2009 09:43:06 -0400
Received: by qw-out-2122.google.com with SMTP id 5so756709qwd.37
        for <netdev@vger.kernel.org>; Sun, 20 Sep 2009 06:43:10 -0700 (PDT)
In-Reply-To: <908876.76571.qm@web111609.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-09-20 at 02:58 -0700, Xiaofei Wu wrote:

> When the link A-B is not available, 

How do you detect this? Is it a path that is broken or a link?

> Could iproute2 'tc' do this?


you could use iproute2 'ip' which supports multi-nexthops, example
off top of my head (for exact syntax run "ip route help")
----
ip route add blah/24 nexthop via a.b.c.d dev wlan0 \
	    nexthop via e.f.g.h dev wlan1 
----

You will probably need to help it by flushing route cache.
You may need to worry about loops on mirroring when the route flipping
happens and need to optimize for that. Please experiment.

cheers,
jamal


