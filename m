From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [CORRECTION][PATCH] Fix a potential NULL pointer dereference
 in uli526x_interrupt() in drivers/net/tulip/uli526x.c
Date: Thu, 13 Sep 2007 10:16:42 -0400
Message-ID: <46E9464A.2020905@pobox.com>
References: <46DD13CE.6010905@gmail.com> <20070913020346.979647c1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Micah Gruber <micah.gruber@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Grant Grundler <grundler@parisc-linux.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757451AbXIMORE@vger.kernel.org>
In-Reply-To: <20070913020346.979647c1.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> --- a/drivers/net/tulip/uli526x.c~fix-a-potential-null-pointer-dereference-in-uli526x_interrupt
> +++ a/drivers/net/tulip/uli526x.c
> @@ -666,11 +666,6 @@ static irqreturn_t uli526x_interrupt(int
>  	unsigned long ioaddr = dev->base_addr;
>  	unsigned long flags;
>  
> -	if (!dev) {
> -		ULI526X_DBUG(1, "uli526x_interrupt() without DEVICE arg", 0);
> -		return IRQ_NONE;
> -	}
> -


correct / ACK
