From: jamal <hadi@cyberus.ca>
Subject: Re: [iproute2] tc action mirred question
Date: Tue, 08 Sep 2009 10:10:44 -0400
Message-ID: <1252419044.5244.17.camel@dogo.mojatatu.com>
References: <404956.88336.qm@web111607.mail.gq1.yahoo.com>
	 <1252376168.5244.11.camel@dogo.mojatatu.com>
	 <f4f837ab0909080650t343efbmeb2f121def40bd9f@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas yang <lampsu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:39858 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754447AbZIHONX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2009 10:13:23 -0400
Received: by qw-out-2122.google.com with SMTP id 9so8814qwb.37
        for <netdev@vger.kernel.org>; Tue, 08 Sep 2009 07:13:25 -0700 (PDT)
In-Reply-To: <f4f837ab0909080650t343efbmeb2f121def40bd9f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-09-08 at 21:50 +0800, thomas yang wrote:

> He want to route the mirroring packets.
> 
> " - Mirror takes a copy of the packet and sends it to specified
>  dev ("port" in ethernet switch/bridging terminology)
>  - redirect
>  steals the packet and redirects to specified destination dev. "
> 
> So,'mirror' is different from 'redirect'.  Change the line 'action
> mirred egress redirect dev eth0' to 'action mirred egress mirror dev
> eth0' .
> Both 'mirror' and 'redirect'  can transmit the packets to otner node,
> but mirror make a copy, then transmit it;  redirect steals the packet,
> right  ?
> 

Yes, of course. That was an example on how to use pedit. If you want
to be pedantic then note that no eth1 device is being used in the
original example and neither is itsensible to make changes to the MAC
address on ingress ;->
In any case, please go and run some experiments to test the theories.

cheers,
jamal

