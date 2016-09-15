From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: cdc_ncm driver padding problem (WAS: Question about
 CDC_NCM_FLAG_NDP_TO_END)
Date: Fri, 16 Sep 2016 01:46:25 +0200 (CEST)
Message-ID: <alpine.LNX.2.20.1609160141270.19559@localhost.localdomain>
References: <57D41536.2090102@gmail.com> <57D437E4.2000708@gmail.com> <alpine.LNX.2.20.1609111517350.30036@localhost.localdomain> <15569aad-22e2-aa4d-e7f1-832063c6490a@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Bjron Mork <bjorn-yOkvZcmFvRU@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marek Brudka <mbrudka-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <15569aad-22e2-aa4d-e7f1-832063c6490a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello guys.
Some very good people managed to detect there is a problem with some Huawei firmwares and NCM padding. I actually don't think I have the hardware to test btw.

On Wed, 14 Sep 2016, Marek Brudka wrote:
Sorry Marek - I forwarded this message without asking for your consent. Let me know anyway if this is a problem. thank you all guys for everything,
Enrico

==Date: Wed, 14 Sep 2016 19:31:50
==From: Marek Brudka <mbrudka-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
==To: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
==Subject: Re: Question about CDC_NCM_FLAG_NDP_TO_END
==
==Hello Enrico,
==
==As nobody at openwrt forum replied to my request on the way how to get
==the exact
==recompilation of OpenWrt 15.05.1 I decided to switch to the developement
==version
==(12/09/2016), which already contains your patch.
==
==The nice thing is that I got my modem (E3372 HiLink reflashed to E398)
==working
==in ncm mode!
==
==The bad thing is DHCP. It seems, that cdc_ncm driver somehow consumes DHCP
==replies. I had to manually setup wwan0 interface as well as routing
==using the result
==of Hayes command
==
==AT^DHCP?
==^DHCP:
==EC684764,F8FFFFFF,E9684764,E9684764,356002D4,366002D4,43200000,43200000
==OK
==
==Certainly, I will modify connect scripts
==   
==https://github.com/zabbius/smarthome/tree/master/openwrt/huawei-ncm/files/usr/sbin
==for me to parse this response. However it seems, that the problem is on
==driver level and
==is related with padding. Do you know this issue which is nicely
==described in the thread
==    https://forum.openwrt.org/viewtopic.php?pid=273099
==of OpenWrt forum?
==
==Thank you
==Marek Brudka
==
==
==W dniu 11.09.2016 o 15:19, Enrico Mioso pisze:
==> Hello Marek.
==>
==> First of all, thank you for your interest in this driver, and for writing.
==>
==> Unfortunately, I don't know the exact procedure to do that: you might be confortable putting those patches in generic-patches-kernel_version if I am not wrong, but I may well be wrong or imprecise, and recompile the whole Openwrt thing?
==> don't know. But yes, that message should appear in the dmesg.
==> NDPs need to be at end of NCM frames. Oh, I don't remember well what NDP stands for... ufh. Sorry.
==>
==> Anyway, let me know if I can do something for you.
==> Enrico
==>
==
==
==
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
