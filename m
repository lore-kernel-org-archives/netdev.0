From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [RFC] make per interface sysctl entries configurable
Date: Mon, 26 Oct 2009 00:32:32 +0200
Message-ID: <200910260032.32303.denys@visp.net.lb>
References: <200910251954.49700.opurdila@ixiacom.com> <4AE4C50F.7060605@gmail.com> <200910260021.48785.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cosmin Ratiu <cratiu@ixiacom.com>, netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:34594 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754285AbZJYWcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2009 18:32:39 -0400
In-Reply-To: <200910260021.48785.opurdila@ixiacom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 26 October 2009 00:21:48 Octavian Purdila wrote:

> Very good point, I think this is the best solution for people using a
> moderately high number of interfaces (a few thousand).
>
> But for really large setups there is another issue: memory consumption. In
> fact, in order to be able to scale to 128K interfaces and still have a
> significant amount of memory available to applications we also had to
> disable sysfs and #ifdef CONFIG_SYSFS struct device from net_device.
>
> I would also argue that when you have such a large number of interfaces you
> don't need to change setting on a per interface basis. Or at least this is
> our case :)  and I suspect that the case with a large number of PPP
> interfaces is similar.
I will add also, sysctl -a (over busybox) on pppoe with 2k interfaces takes 
ages to complete.
