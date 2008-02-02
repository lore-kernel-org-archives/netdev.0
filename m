From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: [NET_SCHED 00/04]: External SFQ classifiers/flow classifier
Date: Sat, 02 Feb 2008 15:23:45 -0800
Message-ID: <47A4FB81.80700@fatooh.org>
References: <20080131175758.25151.20370.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:34442 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763771AbYBBXXt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Feb 2008 18:23:49 -0500
In-Reply-To: <20080131175758.25151.20370.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> These patches add support for external classifiers to SFQ and add a
> new "flow" classifier, which can do hashing based on user-specified
> keys or deterministic mapping of keys to classes. Additionally there
> is a patch to make the SFQ queues visisble as classes to verify that
> the hash is indeed doing something useful and a patch to consifiy
> struct tcf_ext_map, which I had queued in the same tree.

Excellent! I'm glad this is applied. I'm having trouble figuring out how
it works, though. As a test, I'm trying to set up SFQ equivalent to
ESFQ's "hash dst". Here's what I do, and this is what I get:

------------------------------------------------------------------------
# ./tc qdisc add dev eth0 root handle 1: sfq
# ./tc filter add dev eth0 parent 1: flow hash keys dst
RTNETLINK answers: Invalid argument
We have an error talking to the kernel
------------------------------------------------------------------------

I've tried a few different keys with the same results. I don't know what
I'm doing wrong, or even where to start figuring it out. Can you point
me in the right direction?

Here are some details that may be pertinent:

- current net-2.6 git (I double-checked)
- CONFIG_NET_CLS_FLOW=y
- current iproute2 git
- running on amd64 user-mode Linux


Thanks,
Corey
