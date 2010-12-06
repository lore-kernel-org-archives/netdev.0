From: "Gustavo F. Padovan" <padovan@profusion.mobi>
Subject: Re: [PATCH 1/2] vsprintf: Add %pMbt, bluetooth mac address
Date: Mon, 6 Dec 2010 16:11:27 -0200
Message-ID: <20101206181127.GB883@vigoh>
References: <cover.1291419007.git.joe@perches.com>
 <a33a0b00eeb29713a08d91156cbb2d816176f990.1291419007.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcel Holtmann <marcel@holtmann.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <a33a0b00eeb29713a08d91156cbb2d816176f990.1291419007.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,

* Joe Perches <joe@perches.com> [2010-12-03 18:33:03 -0800]:

> Bluetooth output the MAC address in reverse order.
> Bluetooth memory order: 00 01 02 03 04 05 is output "05:04:03:02:01:00".
> 
> This can save overall text when bluetooth is compiled in.
> 
> Bluetooth currently uses a very slightly unsafe local function (batostr)
> to output these formatted addresses.
> 
> Adding %pMbt allows the batostr function to be removed.
> 
> For x86:
> 
> $ size lib/vsprintf*.o*
>    text	   data	    bss	    dec	    hex	filename
>    8189	      0	      2	   8191	   1fff	lib/vsprintf.o.defconfig.new
>    8150	      0	      2	   8152	   1fd8	lib/vsprintf.o.defconfig.old
>   18633	     56	   3936	  22625	   5861	lib/vsprintf.o.allyesconfig.new
>   18571	     56	   3920	  22547	   5813	lib/vsprintf.o.allyesconfig.old
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Looks good to me.

Acked-by: Gustavo F. Padovan <padovan@profusion.mobi>

-- 
Gustavo F. Padovan
http://profusion.mobi
