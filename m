From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Fix locking bug in lltx path
Date: Mon, 13 Sep 2004 12:18:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040913121859.44fbf949.davem@redhat.com>
References: <m3vfei9gzv.fsf@averell.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, arjanv@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <m3vfei9gzv.fsf@averell.firstfloor.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 13 Sep 2004 20:11:00 +0200
Andi Kleen <ak@muc.de> wrote:

> Thanks to Arjan's spinlock debug kernel for finding it.
> 
> This fixes a silly missing spin lock in the relock path. For some 
> reason it seems to still work when you don't have spinlock debugging
> enabled.
> 
> Please apply.

Good catch, but I'll need to fix this up to use the new macros
defined in linux/netdevice.h

Thanks again.
