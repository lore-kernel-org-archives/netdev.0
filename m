From: Con Kolivas <kernel@kolivas.org>
Subject: [PATCH]b44poll - whitespace
Date: Wed, 13 Oct 2004 09:26:46 +1000
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <cone.1097623606.213849.12364.502@pc.kolivas.org>
References: <416BC26B.6090603@kolivas.org> <20041012180949.GW5414@waste.org> <416C5122.9040001@kolivas.org> <20041012215732.GV31237@waste.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_pc.kolivas.org-1097623606-0000"
Cc: Con Kolivas <kernel@kolivas.org>, netdev@oss.sgi.com,
	linux kernel mailing list <linux-kernel@vger.kernel.org>,
	davem@redhat.com, Jeff Garzik <jgarzik@pobox.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268051AbUJLX1Q@vger.kernel.org>
To: Matt Mackall <mpm@selenic.com>
List-Id: netdev.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_pc.kolivas.org-1097623606-0000
Content-Type: text/plain; format=flowed; charset="US-ASCII"
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

>> >+       disable_irq(dev->irq);
>> >+       b44_interrupt (dev->irq, dev, NULL);
>> >+       enable_irq(dev->irq);
>> >
> Stray space between b44_interrupt and args. 

Must have had my eyes closed. Trivial cleanup patch attached, thanks.

Con


--=_pc.kolivas.org-1097623606-0000
Content-Description: b44poll-ws.diff
Content-Disposition: inline;
  FILENAME="b44poll-ws.diff"
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

Index: linux-2.6.9-rc4-ck1/drivers/net/b44.c
===================================================================
--- linux-2.6.9-rc4-ck1.orig/drivers/net/b44.c	2004-10-12 21:28:12.000000000 +1000
+++ linux-2.6.9-rc4-ck1/drivers/net/b44.c	2004-10-13 09:24:46.064825491 +1000
@@ -1309,7 +1309,7 @@ err_out_free:
 static void b44_poll_controller(struct net_device *dev)
 {
 	disable_irq(dev->irq);
-	b44_interrupt (dev->irq, dev, NULL);
+	b44_interrupt(dev->irq, dev, NULL);
 	enable_irq(dev->irq);
 }
 #endif

--=_pc.kolivas.org-1097623606-0000--
