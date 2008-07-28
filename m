From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: Re: [PATCH] smc91c92_cs: use request_firmware
Date: Mon, 28 Jul 2008 10:28:14 +0200
Message-ID: <20080728082814.GA4708@isilmar.linta.de>
References: <1217170341.3537.9.camel@jaswinder.satnam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, dahinds@users.sourceforge.net,
	becker@scyld.com, x-csrdh@jcu.edu.au, erik@vt.edu,
	Jeff Garzik <jeff@garzik.org>, netdev <netdev@vger.kernel.org>,
	David Woodhouse <dwmw2@infradead.org>
To: Jaswinder Singh <jaswinder@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754896AbYG1I20@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1217170341.3537.9.camel@jaswinder.satnam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Sun, Jul 27, 2008 at 08:22:21PM +0530, Jaswinder Singh wrote:
> +static int osi_load_firmware(struct pcmcia_device *link)
> +{
> +	struct platform_device *pdev;
> +	const struct firmware *fw;
> +	const char fw_name[] = "ositech/Xilinx7OD.bin"; 
> +	int i, err;
> + 
> +	pdev = platform_device_register_simple("ositech", 0, NULL, 0);

Why do we need a platform_device here? Can't we just use the pcmcia device
(so &link->dev) here?

Thanks,
	Dominik
