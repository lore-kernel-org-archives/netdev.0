From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: [PATCH 0/9] Fix leaking of kernel heap addresses in net/
Date: Sun, 07 Nov 2010 12:25:14 -0500
Message-ID: <1289150714.3090.158.camel@Dan>
References: <1289147492.3090.137.camel@Dan>
	 <1289149416.2478.143.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, remi.denis-courmont@nokia.com,
	netdev@vger.kernel.org, security@kernel.org, stable@kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:63816 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752650Ab0KGRZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 12:25:17 -0500
In-Reply-To: <1289149416.2478.143.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> NACK
> 
> Thats a pretty stupid patch series, sorry.
> 

I think it might be more constructive to avoid childish name-calling and
instead try to guide the conversation in a way that produces a patch
that would better fit your needs.  Even if you don't agree with the
approach, it's certainly not "stupid".

> You are basically ruining a lot of debugging facilities we use every day
> to find and fix _real_ bugs. The bugs that happen to crash machines of
> our customers.

I'm going to give you the benefit of the doubt and assume you're not
implying that security issues aren't "real" bugs, because that would be
utterly ridiculous.

> 
> If you want to avoid a user reading kernel syslog, why dont you fix the
> problem for non root users able to "dmesg" ? I personally dont care.
> 

This is simply the reality of the current situation.  At least while the
kernel syslog is available to unprivileged users, we need to be more
careful of what is visible through there.

> I am a root user on my machine, I _want_ to have some pretty basic
> informations so that I can work on it, and I believe my work is useful.
> 
> There are pretty easy ways to not disclose "information", but your way
> of using '0' for all values is the dumbest idea one could ever had.

I'm glad I'm capable of producing "the dumbest idea one could ever had".
You seem to be quite set on convincing unpaid volunteers such as myself
to stop sending in patches.

> 
> A single XOR with a "root only visible, random value chosen at boot"
> would be OK. At least we could continue our work, with litle burden.

Finally, a useful contribution.  I'll consider this option after hearing
from a few more people on the subject.

-Dan

