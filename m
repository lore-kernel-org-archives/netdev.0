From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] [TRIVIAL] "unsigned char"/"char" consistency?
Date: Sat, 24 Jan 2004 10:02:33 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040124.100233.41638116.davem@redhat.com>
References: <4012A5F5.2000804@samwel.tk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bart@samwel.tk
In-Reply-To: <4012A5F5.2000804@samwel.tk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Bart Samwel <bart@samwel.tk>
   Date: Sat, 24 Jan 2004 18:05:57 +0100

   I was just nosing around and I noticed a minor inconsistency in the 
   usage of unsigned chars in skbuff push/pull functions. Almost all of 
   these functions return unsigned chars, but there are two that return 
   regular chars. Of course, this might be intentional, but AFAICS it 
   probably isn't. If nobody has a reason why this must be like this, I 
   suggest changing those two functions to return unsigned char as well. 
   I've attached a patch that does this, it's against 2.6.2-rc1.

Patch applied, thanks Bart.
