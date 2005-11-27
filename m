From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH 2.4] sis900: come alive after temporary memory shortage
Date: Sun, 27 Nov 2005 06:35:15 -0200
Message-ID: <20051127083515.GA20701__34199.5892850266$1133101415$gmane$org@logos.cnet>
References: <438829AF.8060101@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Konstantin Khorenko <khorenko@sw.ru>,
        netdev@oss.sgi.com, Daniele Venzano <venza@brownhat.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Vasily Averin <vvs@sw.ru>
Content-Disposition: inline
In-Reply-To: <438829AF.8060101@sw.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Nov 26, 2005 at 12:23:59PM +0300, Vasily Averin wrote:
> Hello Marcelo,
> 
> I would like to inform you that unfortunately the committed patch is wrong
> http://www.kernel.org/git/?p=linux/kernel/git/marcelo/linux-2.4.git;a=commit;h=ecf3337f76eaa94c5a771308d184dc248b74b725
> 
> +	int rx_work_limit =
> +		(sis_priv->dirty_rx - sis_priv->cur_rx) % NUM_RX_DESC;
> 
> when dirty_rx = cur_rx it computes limit=0, but should be NUM_RX_DESC
> 
> Could you please drop the wrong patch and use a new one based on the version
> approved by Daniele Venzano and Jeff Garzik
> http://www.kernel.org/git/?p=linux/kernel/git/jgarzik/netdev-2.6.git;a=commitdiff_plain;h=7380a78a973a8109c13cb0e47617c456b6f6e1f5;hp=b2795f596932286ef12dc08857960d654f577405


Will do - thanks Vasily.
