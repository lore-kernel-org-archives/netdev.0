From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: htb parallelism on multi-core platforms
Date: Sat, 18 Apr 2009 00:41:38 +0200
Message-ID: <49E905A2.7040402@gmail.com>
References: <1239964844.21569.57.camel@blade.ines.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Radu Rendec <radu.rendec@ines.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.186]:20371 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051AbZDQWuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 18:50:00 -0400
Received: by fk-out-0910.google.com with SMTP id 18so497465fkq.5
        for <netdev@vger.kernel.org>; Fri, 17 Apr 2009 15:49:58 -0700 (PDT)
In-Reply-To: <1239964844.21569.57.camel@blade.ines.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Radu Rendec wrote, On 04/17/2009 12:40 PM:

> Hi,

Hi Radu,

> 
> I'm using htb on a dedicated shaping machine. Under heavy traffic (high
> packet rate) all htb work is done on a single cpu - only one ksoftirqd
> is consuming cpu power.
> 
> I have limited network stack knowledge, but I guess all htb work for a
> particular interface is done on the same softirq context. Of course this
> does not scale with multiple cpus, since only one of them would be used.
> 
> Is there any (simple) approach to distribute htb work (for one
> interface) on multiple cpus?

I don't know about anything (simple) for this, but I wonder if you
tried already any htb tweaking like htb_hysteresis module param or
burst/cburst class parameters to limit some maybe useless resolution/
overhead?

Regards,
Jarek P.
