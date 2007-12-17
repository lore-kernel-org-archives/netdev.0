From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: Re: Please pull 'upstream-jgarzik' branch of wireless-2.6
Date: Mon, 17 Dec 2007 18:40:31 -0500
Message-ID: <476708EF.10403@garzik.org>
References: <20071216043419.GF3096@tuxdriver.com> <47670514.4030204@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <47670514.4030204-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hum, this required merging also, and broke the build too :/

drivers/net/wireless/iwlwifi/iwl3945-base.c: In function=20
=91iwl3945_alive_start=92:
drivers/net/wireless/iwlwifi/iwl3945-base.c:6285: error: implicit=20
declaration of function =91iwl_rate_control_unregister=92
make[4]: *** [drivers/net/wireless/iwlwifi/iwl3945-base.o] Error 1
make[3]: *** [drivers/net/wireless/iwlwifi] Error 2
make[2]: *** [drivers/net/wireless] Error 2
make[1]: *** [drivers/net] Error 2
make: *** [drivers] Error 2

I'll leave it there and assume that you will send a fix --on top of--=20
netdev#upstream ...
