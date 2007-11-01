From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] Hide the dead code in the net_namespace.c
Date: Thu, 01 Nov 2007 00:45:06 -0700 (PDT)
Message-ID: <20071101.004506.181932020.davem@davemloft.net>
References: <4728D54F.2080208@openvz.org>
	<4728D773.5090402@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50142
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753727AbXKAHpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 03:45:07 -0400
In-Reply-To: <4728D773.5090402@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 31 Oct 2007 22:28:51 +0300

> The namespace creation/destruction code is never called
> if the CONFIG_NET_NS is n, so it's OK to move it under
> appropriate ifdef.
> 
> The copy_net_ns() in the "n" case checks for flags and
> returns -EINVAL when new net ns is requested. In a perfect
> world this stub must be in net_namespace.h, but this
> function need to know the CLONE_NEWNET value and thus
> requires sched.h. On the other hand this header is to be
> injected into almost every .c file in the networking code,
> and making all this code depend on the sched.h is a
> suicidal attempt.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
