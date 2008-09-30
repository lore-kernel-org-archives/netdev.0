From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] negative dev use in /proc/net/rose_neigh
Date: Tue, 30 Sep 2008 07:32:13 -0700 (PDT)
Message-ID: <20080930.073213.60770455.davem@davemloft.net>
References: <200809282156.39466.bpidoux@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bpidoux@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36842
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752579AbYI3OcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 10:32:25 -0400
In-Reply-To: <200809282156.39466.bpidoux@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bernard Pidoux <bpidoux@free.fr>
Date: Sun, 28 Sep 2008 21:56:38 +0200

> I propose the following patch to avoid use counter underflow.
> However a KERN_WARNING message could be better instead of KERN_ERR.

I don't see any large value in adding this patch right now.
At best it's a new BUG check, it doesn't actually fix the
problem.  I'd rather apply a fix :-)
