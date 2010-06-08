From: Christoph Fritz <chf.fritz@googlemail.com>
Subject: Re: BUG: double spinlock in "drivers/net/3c505.c"
Date: Tue, 08 Jun 2010 15:26:45 +0200
Message-ID: <1276003605.3916.14.camel@lovely>
References: <201006071517.28744.strakh@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Philip Blundell <philb@gnu.org>,
	Craig Southeren <craigs@ineluki.apana.org.au>,
	Andrew Tridgell <tridge@nimbus.anu.edu.au>,
	Alan Cox <Alan.Cox@linux.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexander Strakh <strakh@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201006071517.28744.strakh@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-06-07 at 15:17 +0400, Alexander Strakh wrote: 
> 	KERNEL_VERSION: 2.6.35-rc1
>         SUBJECT: duble spinlock  in function elp_start_xmit

Not only in elp_start_xmit. This driver is for a pretty old and slow isa
ethernet card and I think nobody cares. To quote a comment from the
source: "[...] the concurrency protection is particularly awful".

Thanks, 
   Christoph
