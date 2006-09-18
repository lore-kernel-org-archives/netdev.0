From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [BNEP] Fix compat BNEPGETCONNLIST ioctl.
Date: Mon, 18 Sep 2006 12:38:19 +0200
Message-ID: <1158575899.25125.1.camel@localhost>
References: <1158573909.24527.336.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: torvalds@osdl.org, akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:52867 "EHLO
	mail.holtmann.net") by vger.kernel.org with ESMTP id S965640AbWIRKiQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 06:38:16 -0400
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1158573909.24527.336.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

> We were making no attempt to deal with the fact that a structure with a
> uint32_t followed by a pointer is going to be _different_ for 32-bit and
> 64-bit userspace. Any 32-bit process trying to use BNEPGETCONNLIST will
> be failing with -EFAULT if it's lucky; suffering from having the
> connection list dumped at a random address if it's not.

it seems that HIDP and CMTP will have the same problem.

Regards

Marcel


