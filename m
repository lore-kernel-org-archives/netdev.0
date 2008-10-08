From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: small design problem with hso driver
Date: Wed, 08 Oct 2008 15:52:38 +0200
Message-ID: <48ECBB26.7080402@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,
I'm getting a fairly consistently reproducable problem
with the 3g modem hso driver. The most reproducable
bug I have.

It happens when I plug out the usb modem & ctrl-c
out of an ioctl call with the modem connected in paralell over ppp
with wvdial 

Basically whats happening is the hso_serial_close
is being called more times than the hso_serial_open &
I don't know why.

I can put in a kludge to cure the symptom which would prevent the crash
but it would be nice to know why this might be
happening.


-- 
best regards,
D.J. Barrow
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
