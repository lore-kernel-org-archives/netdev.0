From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH][ATM]: [lanai] ioctl only meant for debugging (from mitch@sfgoth.com)
Date: Tue, 23 Sep 2003 07:42:42 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309231142.h8NBgfkT023226@ginger.cmf.nrl.navy.mil>
References: <davem@redhat.com>
Cc: hch@infradead.org, netdev@oss.sgi.com, mitch@sfgoth.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: Message from "David S. Miller" <davem@redhat.com>
   of "Tue, 23 Sep 2003 03:57:29 PDT." <20030923035729.2aa1afd6.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20030923035729.2aa1afd6.davem@redhat.com>,"David S. Miller" writes:
>On Mon, 22 Sep 2003 13:55:07 -0400
>chas williams <chas@cmf.nrl.navy.mil> wrote:
>
>> i suppose i am not convinced that two #ifdef/#endif's are better than an
>> #if/#else/#endif
>
>True, but how about we use an LANAI_DEBUG or something instead of "#if
>0" that can sit undef'd at the top of the file?

i suppose i might suggest DEBUG_RW which already exists in the code.

/*
 * Debug _all_ register operations with card, except the memory test.
 * Also disables the timed poll to prevent extra chattiness.  This
 * isn't for normal use
 */
#undef DEBUG_RW

DEBUG seems to be typically defined so isnt a great choice.  any
comments mitch?
