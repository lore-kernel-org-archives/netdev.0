From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Don't call request_module() under spinlock in
 xfrm_get_type()
Date: Tue, 08 Jul 2003 19:30:07 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030708.193007.26293028.davem@redhat.com>
References: <Mutt.LNX.4.44.0307062238010.468-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
In-Reply-To: <Mutt.LNX.4.44.0307062238010.468-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: James Morris <jmorris@intercode.com.au>
   Date: Sun, 6 Jul 2003 22:42:40 +1000 (EST)

   This patch fixes a problem where request_module() was being called
   under the lock taken in xfrm_policy_get_afinfo().

Looks good, applied.
