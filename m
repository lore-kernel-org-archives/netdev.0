From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [NET] Exporting of some IPv6 symbols for HIP and SHIM6
 experimentation
Date: Tue, 06 May 2008 19:18:48 +0900 (JST)
Message-ID: <20080506.191848.37229806.yoshfuji@linux-ipv6.org>
References: <Pine.SOL.4.64.0805050847400.8815@kekkonen.cs.hut.fi>
	<20080505.150045.29715304.yoshfuji@linux-ipv6.org>
	<Pine.SOL.4.64.0805061052470.28110@kekkonen.cs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: miika@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:38644 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753AbYEFKSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 06:18:38 -0400
In-Reply-To: <Pine.SOL.4.64.0805061052470.28110@kekkonen.cs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <Pine.SOL.4.64.0805061052470.28110@kekkonen.cs.hut.fi> (at Tue, 6 May 2008 11:07:49 +0300 (EEST)), Miika Komu <miika@iki.fi> says:

> > Miika, where are your other patches on top of this?
> > This kind of change might be okay, but it must be along with
> > its users, at least.
> 
> we are maintaining a separate kernel module (GPLv2) for the HIP socket 
> handler for experimentation purposes. If you want to have a look it, you 
> can e.g. download the nightly tarball and have a look at the hipsock 
> directory:
> 
> http://infrahip.hiit.fi/hipl/hipl.tar.gz

Even though, we basically do not accept patches without in-kernel users.

Anyway, I've quickly looked into the code, and IMHO
it is better to avoid using hip_select_socket_handler() and
to introduce new hip_ops (or something) in sock{}.

And, are you working on IPv4 transport?

--yoshfuji
