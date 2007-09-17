From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [2.6.23-rc4-mm1][Bug] kernel BUG at
 include/linux/netdevice.h:339!
Date: Mon, 17 Sep 2007 14:16:22 -0700
Message-ID: <20070917141622.330b27b8.akpm@linux-foundation.org>
References: <46EE7026.2070203@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932836AbXIQVSm@vger.kernel.org>
In-Reply-To: <46EE7026.2070203@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 17 Sep 2007 17:46:38 +0530
Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:

> Kernel Bug is hit with 2.6.23-rc4-mm1 kernel on ppc64 machine.
> 
> kernel BUG at include/linux/netdevice.h:339!

(please cc netdev@vger.kernel.org on networking-related matters)

You died here:

static inline void napi_complete(struct napi_struct *n)
{
        BUG_ON(!test_bit(NAPI_STATE_SCHED, &n->state));

The NAPI changes have had a few problems and hopefully things have
been fixed up since then.  I'll try to get rc6-mm1 out this evening,
so please retest that?
