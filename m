From: "David S. Miller" <davem@redhat.com>
Subject: Re: [Panic] 2.6.8 and ingress scheduling
Date: Sun, 15 Aug 2004 19:45:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040815194555.1990f313.davem@redhat.com>
References: <20040814175233.GA3617@lazy.shacknet.nu>
	<20040815130635.GA3703@lazy.shacknet.nu>
	<411F8B50.2020402@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lkml@lazy.shacknet.nu, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <411F8B50.2020402@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 15 Aug 2004 18:12:00 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Fixed by this patch. qdisc_data was only aligned correctly in 
> qdisc_create_dflt(),
> not qdisc_create() which resulted in memory corruption.

Oops, thanks Patrick.  Patch applied.
