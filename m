From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] selinux: add a skb_owned_by() hook
Date: Tue, 09 Apr 2013 07:39:51 -0400
Message-ID: <3051849.MEUSbRlHa1@sifl>
References: <6182509.cOVcY8B4g7@sifl> <5163992F.30406@schaufler-ca.com> <20130409.004144.1226810973846202358.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	mvadkert@redhat.com, linux-security-module@vger.kernel.org
To: David Miller <davem@davemloft.net>, casey@schaufler-ca.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12191 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934576Ab3DILj5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 07:39:57 -0400
In-Reply-To: <20130409.004144.1226810973846202358.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, April 09, 2013 12:41:44 AM David Miller wrote:
> It makes sure SYN/ACKs have a socket context attached to the
> packet, which only LSMs actually need.
> 
> You participated in the thread where this stuff was discussed and the
> initial version of this patch was posted, so this patch, or any aspect
> of it, should not be a mystery.

Casey, and the LSM list as a whole, was not included in the entire thread as 
when I first posted my original patch I believed the "mergeable" fix was going 
to be self contained within the network stack.

For Casey, and others on the LSM list, here is a pointer to the original 
thread which started on netdev.  Enjoy.

 * http://marc.info/?t=136543607500006&r=1&w=2

-- 
paul moore
security and virtualization @ redhat
