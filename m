From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: [patch] 2.4 lacks dummy SET_NETDEV_DEV
Date: Tue, 2 Dec 2003 12:40:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031202104024.GA9163@ee.oulu.fi>
References: <20031110181917.GA25846@ee.oulu.fi> <20031110221430.GA26556@ee.oulu.fi> <20031110221429.04732a57.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: marcelo.tosatti@cyclades.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20031110221429.04732a57.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 10, 2003 at 10:14:29PM -0800, David S. Miller wrote:
> On Tue, 11 Nov 2003 00:14:30 +0200
> Pekka Pietikainen <pp@ee.oulu.fi> wrote:
> 
> > (I still like the idea of being able to use exactly the same driver
> > source on 2.4/2.6 though)
> 
> I agree, someone should merge in the dummy SET_NETDEV_DEV once
> Marcelo starts up 2.4.24-preX
Ping :-)

--- linux-2.4.22-1.2115.nptl/include/linux/netdevice.h.orig	2003-11-10 20:08:42.922635848 +0200
+++ linux-2.4.22-1.2115.nptl/include/linux/netdevice.h	2003-11-10 20:09:09.754556776 +0200
@@ -456,6 +456,8 @@
 #endif /* CONFIG_NET_DIVERT */
 };
 
+/* 2.6 compatibility */
+#define SET_NETDEV_DEV(net, pdev) do { } while (0)
 
 struct packet_type 
 {

-- 
Pekka Pietikainen
