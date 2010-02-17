From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 1/2] usbnet: Convert dev(dbg|err|warn|info)
 macros to netdev_<level>
Date: Tue, 16 Feb 2010 23:37:14 -0800 (PST)
Message-ID: <20100216.233714.39181977.davem@davemloft.net>
References: <20100212.123837.56526847.davem@davemloft.net>
	<48cb1d6445dceaa7043d1039ca775a8961020d88.1266221693.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david-b@pacbell.net, gregkh@suse.de, tilman@imap.cc,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <48cb1d6445dceaa7043d1039ca775a8961020d88.1266221693.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 15 Feb 2010 00:25:11 -0800

> These macros are too similar to the dev_<level> equivalents
> but take a usbnet * argument.  Convert them to the recently
> introduced netdev_<level> macros and remove the old macros.
> 
> The old macros had "\n" appended to the format string.
> Add the "\n" to the converted uses.
> 
> Some existing uses of the dev<foo> macros in cdc_eem.c
> probably mistakenly had trailing "\n".  No "\n" added there.
> 
> Fix net1080 this/other log message inversion.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
