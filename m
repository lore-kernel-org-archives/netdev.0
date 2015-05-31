From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [cdc_ncm] guidance and help refactoring cdc_ncm
Date: Sun, 31 May 2015 16:37:11 +0200 (CEST)
Message-ID: <alpine.LNX.2.20.1505311628420.16456@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=US-ASCII
Cc: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello guys.
I am writing to you all to ask for help and assistance in refactoring the 
cdc_ncm driver to support newer devices.
In particular - I would need step-by-step guidance in doing this: or any other 
kind of help would be anyway greatly apreciated.

1 - What we need:
   We would need to refactor the driver to be able to re-order parts of the NCM
   package itself.
   In particular, being a single NCM frame composed of different parts, we would
   need more flexibility in changing their order.
2 - What might be nice
   To do so, it would be nice to have the driver queue up frames, sending them
   out as needed. this already happens to a certain extent, but the NCM package
   is created in the process and updated in the while as I understood the code.
   The best thing would be to have the NCM package created only before sending
   it out, to achieve for best performance and code readability.

I already contactedprivately some of you to have some more insight on what 
needs to be done, and to understand better how to organize the effort. I 
unfortunately miss the time to do this right now: and infact I can't even be 
sure to be able to do this, due to various problems (my tesis, my life in 
general).
But gathering more informations and in general trying to get some help is the 
best thing I feel like doing right now.

The compelling reasons I find for trying to fix the situation are:
1 - The fact these drivers are used in different products integrating or
   interfacing with 3G/4G technologies.
2 - To gain more flexibility in the long term.

Thank you guys for reading this message and everything.
Please keep me in CC since I am not subscribed to this list.

Enrico Mioso
My Tox ID is: 7C593F402A3C8632D87AB4B948D492294C39A6A614464ECF843CA3429FB023284180472C7475

I like / reocmmend usage of open messaging standards: my preferred XMPP ID
(JID) is: mrkiko-aHS423dKhWw@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
