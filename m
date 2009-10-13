From: Frans Pop <elendil@planet.nl>
Subject: Re: (Solved) Problem compile kernel on Ubuntu and using on Debian
Date: Tue, 13 Oct 2009 19:19:31 +0200
Message-ID: <200910131919.32560.elendil@planet.nl>
References: <1255431677.13607.118.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	sam@ravnborg.org
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Cpsmtpm-eml108.kpnxchange.com ([195.121.3.12]:50987 "EHLO
	CPSMTPM-EML108.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760066AbZJMRUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 13:20:13 -0400
In-reply-To: <1255431677.13607.118.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer wrote:
> If you get past this one, by compiling enough modules into the kernel,
> BUT then a lot of modules does not seem to be loaded (modprobe).
[...] 
> Q: I don't know why a depmod update is required, anyone feel free to
> answer that question?

The most likely reason is that the two systems have different, and 
incompatible, versions of module-init-tools.

I've seen the same problem in the past [1] and, after a hefty discussion, 
accepted that you just _have_ to always run depmod -a after installing a 
kernel and before generating an initrd.

Cheers,
FJP

[1] http://bugs.debian.org/518407
