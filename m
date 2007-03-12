From: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Subject: Re: [git patches] net driver fixes
Date: Mon, 12 Mar 2007 11:02:43 +0100 (CET)
Message-ID: <Pine.LNX.4.62.0703121100260.16343@pademelon.sonytel.be>
References: <20070306114808.GA22724@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965481AbXCLKCs@vger.kernel.org>
In-Reply-To: <20070306114808.GA22724@havoc.gtf.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 6 Mar 2007, Jeff Garzik wrote:
> Jay Vosburgh (3):
>       bonding: Improve IGMP join processing

ip_mc_rejoin_group: Kill warning about unused variable `in_dev' when
CONFIG_IP_MULTICAST is not set.

Signed-off-by: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 1c6a084..8cedb2a 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1255,9 +1255,9 @@ out:
  */
 void ip_mc_rejoin_group(struct ip_mc_list *im)
 {
+#ifdef CONFIG_IP_MULTICAST
 	struct in_device *in_dev = im->interface;
 
-#ifdef CONFIG_IP_MULTICAST
 	if (im->multiaddr == IGMP_ALL_HOSTS)
 		return;
 

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- Sony Network and Software Technology Center Europe (NSCE)
Geert.Uytterhoeven@sonycom.com ------- The Corporate Village, Da Vincilaan 7-D1
Voice +32-2-7008453 Fax +32-2-7008622 ---------------- B-1935 Zaventem, Belgium
