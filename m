From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (0/9) free_netdev -- delay freeing of net_device
 structure till after last use
Date: Tue, 19 Aug 2003 13:24:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819132432.4c601c5f.davem@redhat.com>
References: <20030819121800.009db89b.shemminger@osdl.org>
	<20030819124818.476dc36d.davem@redhat.com>
	<3F42877B.9040407@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com, mochel@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F42877B.9040407@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Aug 2003 16:24:27 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Also, my tendency is to apply patches 1-8, and not apply patch 9 just 
> yet.  Even though patch 9 is a fix, those specific areas of code, I'm 
> betting, will change when those drivers are fixed WRT full dynamic 
> allocation and refcounting.
> 
> Comments?

I disagree about patch 9.

These drivers already dynamically allocate their netdev
structs, so they do not require any more fixing.  I just
double checked each driver changes in patch 9 and to me
this is undoubtedly the case.

These are just pure bug fixes.
