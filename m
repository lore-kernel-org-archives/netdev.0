From: Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 01/16] wl1251: fix scan behaviour while not associated
Date: Tue, 10 Dec 2013 17:41:04 +0200
Message-ID: <8738m0r9wv.fsf@purkki.adurom.net>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
	<1386494714-21070-1-git-send-email-pali.rohar@gmail.com>
	<1386494714-21070-2-git-send-email-pali.rohar@gmail.com>
	<20131210092114.GB22756@amd.pavel.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pali =?utf-8?Q?Roh=C3=A1r?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Luciano Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, freemangordon-uiMcrn6V0Vs@public.gmane.org,
	aaro.koskinen-X3B1VOXEql0@public.gmane.org, sre-GFxCN5SEZAc@public.gmane.org, joni.lapilainen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Felipe Contreras <felipe.contreras-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Gnedt <david.gnedt-rFfgOQFw6VLk7+2FdBfRIA@public.gmane.org>
To: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20131210092114.GB22756-tWAi6jLit6GreWDznjuHag@public.gmane.org> (Pavel Machek's message
	of "Tue, 10 Dec 2013 10:21:14 +0100")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org> writes:

> ssids can have \0s in them... and what is worse, they may not be 0
> terminated AFAICT.
>
> Potential solution is at
> http://www.spinics.net/lists/linux-wireless/msg98640.html . 

I just use print_hex_dump_bytes() to print SSIDs.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
