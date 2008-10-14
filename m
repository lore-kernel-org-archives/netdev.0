From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 2.6.27-rc9 QGLE make unsupported page size explicit
 compile failure
Date: Mon, 13 Oct 2008 19:03:45 -0700 (PDT)
Message-ID: <20081013.190345.20202604.davem@davemloft.net>
References: <20081013060615.GB29358@colo.lackof.org>
	<20081012.230939.240550430.davem@davemloft.net>
	<20081014015455.GA25385@susedev.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, linux-driver@qlogic.com,
	netdev@vger.kernel.org, linux-ia64@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <linux-ia64-owner@vger.kernel.org>
In-Reply-To: <20081014015455.GA25385@susedev.qlogic.org>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Mon, 13 Oct 2008 18:54:55 -0700

> Dave/Grant,
> I sent this earlier today but didn't see it on the netdev list.
> Thanks, Ron
> 
> This ASIC does support all page sizes. For 4k and 8k page size the TX control block needs an external scatter gather list.  For page sizes larger than 8k the max frags is satisfied by the original TX control block.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

I'm not applying this.  I _explicitly_ said I would not apply a
solution like this.

I waited for you guys all day for this?!?!

We need to find a way to make this a Kconfig dependency.

Build failures are absolutely unacceptable.

People do randconfig, allyesconfig, allmodconfig, etc. for build
regression testing and that has to work no matter what page size gets
selected or is the default for a given platform.

