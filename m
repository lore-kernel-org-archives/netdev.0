From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Fix 64bit bugs in dscc44.c
Date: Wed, 8 Oct 2003 08:42:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008084205.5c81faac.davem@redhat.com>
References: <20031007175953.GA1802@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ncorbic@sangoma.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20031007175953.GA1802@averell>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 7 Oct 2003 19:59:53 +0200
Andi Kleen <ak@muc.de> wrote:

> ioremap_nocache returns unsigned long, not u32. This makes a difference
> on 64bit hosts.

Incorrect, like ioremap() it returns "void *".

Even your x86_64 implementation does this.
