From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [2.6 patch] drivers/net/wan/: possible cleanups
Date: Mon, 18 Apr 2005 13:55:06 +0100
Message-ID: <1113828904.17058.21.camel@localhost.localdomain>
References: <20050327143418.GE4285@stusta.de>
	 <1111941516.14877.325.camel@localhost.localdomain>
	 <20050414232028.GD20400@stusta.de>
	 <1113587392.11155.33.camel@localhost.localdomain>
	 <20050417234738.GY3625@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050417234738.GY3625@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Llu, 2005-04-18 at 00:47, Adrian Bunk wrote:
> Are there any external drivers using these exports, and if there are, 
> why aren't they in the kernel?

Its a standard API

> If there aren't and someone will at some time in the future need them, 
> re-adding the exports will be trivial.

Really, you will spotaneously magically make them appear in old kernels
that end users have just like that ?

Your argument doesn't hold water. Its an API for drivers so that people
can add 85x30 card drivers using DMA in this fashion. Its an API so they
can add them to *EXISTING* kernels without users being forced to
recompile/wait for the vendor to update their tree/upgrade to a new
release.

Alan
