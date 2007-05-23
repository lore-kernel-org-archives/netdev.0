From: Shane McDonald <Shane_McDonald@pmc-sierra.com>
Subject: RE: [NET] meth driver renovation
Date: Wed, 23 May 2007 13:02:18 -0700
Message-ID: <8A9D56C5E50F774BABE033F1710B3576093B15@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-mips@linux-mips.org
To: "'Ralf Baechle'" <ralf@linux-mips.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

Should this be:

>  static void __exit meth_exit_module(void)
>  {
> -	unregister_netdev(meth_dev);
> -	free_netdev(meth_dev);
> +	platform_driver_register(&meth_driver);
>  }

                      ^^^^^^^^

      platform_driver_unregister(&meth_driver);
                      ^^

Shane
