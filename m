From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit
 kernels.
Date: Thu, 24 Apr 2008 23:27:00 -0700 (PDT)
Message-ID: <20080424.232700.144474920.davem@davemloft.net>
References: <20080425.143845.24767700.yoshfuji@linux-ipv6.org>
	<OF6BB885BC.24376BB7-ON88257436.0021B953-88257436.002315D4@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49015
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755118AbYDYG1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 02:27:01 -0400
In-Reply-To: <OF6BB885BC.24376BB7-ON88257436.0021B953-88257436.002315D4@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Stevens <dlstevens@us.ibm.com>
Date: Thu, 24 Apr 2008 23:23:15 -0700

> I wanted to allocate the copy on the user stack

compat_alloc_user_space(size), as you used it, is the way

On sparc64 I named the "within userspace" copy function
copy_in_user() and this seems to be supported well enough
to be used by the generic compat code elsewhere in the
tree so very likely it's supported everywhere it needs
to be

