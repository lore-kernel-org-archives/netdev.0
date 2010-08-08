From: Komuro <komurojun-mbn@nifty.com>
Subject: Re: [PATCH 11/18] pcmcia: do not use io_req_t when calling
	pcmcia_request_io()
Date: Sun, 8 Aug 2010 22:07:31 +0900 (JST)
Message-ID: <103911.103501281272851252.komurojun-mbn@nifty.com>
References: <1281046014-7585-11-git-send-email-linux@dominikbrodowski.net>
	<20100805220511.GA7040@comet.dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org, linux-usb@vger.kernel.org,
	linux-serial@vger.kernel.org, netdev@vger.kernel.org,
	linux-pcmcia@lists.infradead.org, linux-wireless@vger.kernel.org,
	laforge@gnumonks.org, linux-ide@vger.kernel.org,
	linux-mtd@lists.infradead.org,
	Dominik Brodowski <linux@dominikbrodowski.net>,
	Michael Buesch <mb@bu3sch.de>
To: Dominik Brodowski <linux@dominikbrodowski.net>
Return-path: <linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org>
In-Reply-To: <1281046014-7585-11-git-send-email-linux@dominikbrodowski.net>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-pcmcia>,
	<mailto:linux-pcmcia-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-pcmcia/>
List-Post: <mailto:linux-pcmcia@lists.infradead.org>
List-Help: <mailto:linux-pcmcia-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-pcmcia>,
	<mailto:linux-pcmcia-request@lists.infradead.org?subject=subscribe>
Sender: linux-pcmcia-bounces@lists.infradead.org
Errors-To: linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi,

> 
>-    link->io.IOAddrLines =10;
>-    link->io.Attributes1 = IO_DATA_PATH_WIDTH_16;
>+    link->resource[0]->flags |= IO_DATA_PATH_WIDTH_16;

link->io_lines should be set here?



>@@ -840,14 +839,15 @@ xirc2ps_config(struct pcmcia_device * link)
> 	}
> 	printk(KNOT_XIRC "no ports available\n");
>     } else {
>-	link->io.NumPorts1 = 16;
>+	link->io_lines = 10;
>+	link->resource[0]->end = 16;

Best Regards
Komuro
