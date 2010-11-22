From: "Guy, Wey-Yi" <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 56/62] iwlwifi: Use static const
Date: Mon, 22 Nov 2010 07:37:03 -0800
Message-ID: <1290440223.7946.0.camel@wwguy-ubuntu>
References: <cover.1290305773.git.joe@perches.com>
	 <2773a20a26f4e326f0849e8ae8fb4f347d6a6ecb.1290305776.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>,
	"Chatre, Reinette" <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2773a20a26f4e326f0849e8ae8fb4f347d6a6ecb.1290305776.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Joe,

On Sat, 2010-11-20 at 18:38 -0800, Joe Perches wrote:
> Using static const generally increases object text and decreases data size.
> It also generally decreases overall object size.
> 
>    text	   data	    bss	    dec	    hex	filename
>   48644	     57	  12120	  60821	   ed95	drivers/net/wireless/b43/phy_n.o.new
>   48661	     57	  12120	  60838	   eda6	drivers/net/wireless/b43/phy_n.o.old
>   37906	     86	   7904	  45896	   b348	drivers/net/wireless/iwlwifi/iwl-agn-lib.o.new
>   37937	     86	   7904	  45927	   b367	drivers/net/wireless/iwlwifi/iwl-agn-lib.o.old
>   37781	    523	   6752	  45056	   b000	drivers/net/wireless/iwlwifi/iwl-3945.o.new
>   37781	    523	   6752	  45056	   b000	drivers/net/wireless/iwlwifi/iwl-3945.o.old
> 
> Changed b43_nphy_write_clip_detection to take a const u16 *
> 
> Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
> ---

I don't see size difference on 3945, otherwise the patch looks ok to me

Wey



--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
