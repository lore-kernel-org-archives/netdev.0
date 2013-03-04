From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net] garp: fix a NULL pointer dereference bug
Date: Mon, 04 Mar 2013 17:55:55 +0800
Message-ID: <1362390955.2383.2.camel@cr0>
References: <1362368217-30984-1-git-send-email-amwang@redhat.com>
	 <1362374790.15793.87.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugs@syam.in,
	David Ward <david.ward@ll.mit.edu>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42804 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756673Ab3CDJ4L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Mar 2013 04:56:11 -0500
In-Reply-To: <1362374790.15793.87.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-03-03 at 21:26 -0800, Eric Dumazet wrote:
> 
> Nope this patch doesnt solve the problem
> 
> Crash is in :
> 
> 49 8b 1c c6             mov    (%r14,%rax,8),%rbx 
> 
> Thats because r14 (port) is NULL
> 
> 
> 

Hmm, but I can't see how it can be NULL, the only place of NULL'ing it
is inside garp_release_port(), right after the piece of code that I
patched.

Thanks!
