From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] more direct access of dev->refcnt
Date: Wed, 07 May 2003 12:30:59 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030507.123059.84384241.davem@redhat.com>
References: <20030507132326.0864b07f.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: philb@gnu.org, SteveW@ACM.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030507132326.0864b07f.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Wed, 7 May 2003 13:23:26 -0700

   The following places directly increment dev refcount rather than
   using the inline dev_hold.

Applied, thanks Stephen.
   
   Also, Econet keeps pointers to devices without holding refcount
   which is wrong.

Econet is pure orphan for years, looking for maintainer.

I occaisional consider trying to repair it.
