From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] sys_sendmsg() alignment bug fix
Date: Mon, 26 Sep 2005 21:50:29 -0700 (PDT)
Message-ID: <20050926.215029.97127602.davem@davemloft.net>
References: <1127764921.6529.60.camel@tdi>
	<2cd57c90050926204022fb22ca@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.williamson@hp.com, akpm@osdl.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964807AbVI0Euf@vger.kernel.org>
To: coywolf@gmail.com
In-Reply-To: <2cd57c90050926204022fb22ca@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Coywolf Qi Hunt <coywolf@gmail.com>
Date: Tue, 27 Sep 2005 11:40:38 +0800

> On 9/27/05, Alex Williamson <alex.williamson@hp.com> wrote:
> >    The patch below adds an alignment attribute to the buffer used in
> > sys_sendmsg().  This eliminates an unaligned access warning on ia64.
> 
> Is this a warning fix or bug fix?

It doesn't generate a warning, but it does generate totally
unnecessary unaligned access traps on RISC systems.
