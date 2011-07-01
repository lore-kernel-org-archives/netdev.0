From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Subject: Re: [PATCH] bluetooth: Add bt_printk
Date: Fri, 1 Jul 2011 16:03:27 -0300
Message-ID: <20110701190327.GD23683@joana>
References: <20110630033119.GA3438@joana>
 <f06f1d8f4185db431a038c328c42caf4fe270dd0.1309418368.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <f06f1d8f4185db431a038c328c42caf4fe270dd0.1309418368.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Joe,

* Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> [2011-06-30 00:19:51 -0700]:

> Add a local logging function to emit bluetooth specific
> messages.  Using vsprintf extension %pV saves code/text
> space.
> 
> Convert the current BT_INFO and BT_ERR macros to use bt_printk.
> Remove __func__ from BT_ERR macro (and the uses).
> Prefix "Bluetooth: " to BT_ERR
> Remove __func__ from BT_DBG as function can be prefixed when
> using dynamic_debug.
> 
> With allyesconfig:
> 
>    text	   data	    bss	    dec	    hex	filename
>  129956	   8632	  36096	 174684	  2aa5c	drivers/bluetooth/built-in.o.new2
>  134402	   8632	  36064	 179098	  2bb9a	drivers/bluetooth/built-in.o.old
>   14778	   1012	   3408	  19198	   4afe	net/bluetooth/bnep/built-in.o.new2
>   15067	   1012	   3408	  19487	   4c1f	net/bluetooth/bnep/built-in.o.old
>  346595	  19163	  86080	 451838	  6e4fe	net/bluetooth/built-in.o.new2
>  353751	  19163	  86064	 458978	  700e2	net/bluetooth/built-in.o.old
>   18483	   1172	   4264	  23919	   5d6f	net/bluetooth/cmtp/built-in.o.new2
>   18927	   1172	   4264	  24363	   5f2b	net/bluetooth/cmtp/built-in.o.old
>   19237	   1172	   5152	  25561	   63d9	net/bluetooth/hidp/built-in.o.new2
>   19581	   1172	   5152	  25905	   6531	net/bluetooth/hidp/built-in.o.old
>   59461	   3884	  14464	  77809	  12ff1	net/bluetooth/rfcomm/built-in.o.new2
>   61206	   3884	  14464	  79554	  136c2	net/bluetooth/rfcomm/built-in.o.old
> 
> with x86 defconfig (and just bluetooth):
> 
> $ size net/bluetooth/built-in.o.defconfig.*
>    text	   data	    bss	    dec	    hex	filename
>   66358	    933	    100	  67391	  1073f	net/bluetooth/built-in.o.defconfig.new
>   66643	    933	    100	  67676	  1085c	net/bluetooth/built-in.o.defconfig.old
> 
> Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>

I applied this patch with a minimal change in the print format. I changed
'bluetooth' to 'Bluetooth'. Thanks a lot for the patch. ;)

	Gustavo
