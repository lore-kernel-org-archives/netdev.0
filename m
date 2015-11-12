From: Chris Siebenmann <cks-rhbugzilla@cs.toronto.edu>
Subject: Re: [PATCH net 1/3] ipv6: Avoid creating RTF_CACHE from a rt that is not managed by fib6 tree
Date: Thu, 12 Nov 2015 17:01:01 -0500
Message-ID: <20151112220101.47E8B7A080D@apps0.cs.toronto.edu>
References: <1447271468-3930566-2-git-send-email-kafai@fb.com>
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
	Chris Siebenmann <cks-rhbugzilla@cs.toronto.edu>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cliff.cs.toronto.edu ([128.100.3.120]:40090 "EHLO
	cliff.cs.toronto.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752940AbbKLWRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2015 17:17:00 -0500
In-reply-to: kafai's message of Wed, 11 Nov 2015 11:51:06 -0800.
             <1447271468-3930566-2-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The original bug report:
> https://bugzilla.redhat.com/show_bug.cgi?id=1272571
> 
> The setup has a IPv4 GRE tunnel running in a IPSec.  The bug
> happens when ndisc starts sending router solicitation at the gre
> interface.  The simplified oops stack is like:
[...]
> Reported-by: Chris Siebenmann <cks-rhbugzilla@cs.toronto.edu>

 For what it's worth, this change appears to fix my issue in preliminary
testing. I haven't actually brought it up on a production machine with a
GRE tunnel that actually works, but the sequence of operations on my
test machine that used to reliably oops no longer does so.

(I tested this against both a quite recent upstream git pull and the
current Fedora 22 kernel source with this patch blindly shoved in on top
by just running 'patch'.)

	- cks
