From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Sevaral MLD Fixes
Date: Fri, 18 Oct 2002 18:15:32 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021018.181532.45064096.davem@redhat.com>
References: <20021018.125223.130322644.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20021018.125223.130322644.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Fri, 18 Oct 2002 12:52:23 +0900 (JST)

I am going to apply this patch, but please be more careful
in the future.  You submitted two patches which modify
the same hunk of comment to two different values, guarenteeing
that if I just run 'patch' this one will not apply without rejects.

   @@ -18,6 +18,9 @@
    /* Changes:
     *
     *	yoshfuji	: fix format of router-alert option
   + *	YOSHIFUJI Hideaki @USAGI:
   + *		- Ignore Queries for invalid addresses.
   + *		- MLD for link-local addresses.
     */
    
    #define __NO_VERSION__

Next time, please make patch relative to previous one and
tell me "this patch depends upon MLD source address selection
patch being applied first".

This way we can avoid this problem.
