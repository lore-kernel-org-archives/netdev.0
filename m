From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Subject: Re: [PATCH net-next] drivers/acpi/acpica/utmisc.c: Use printk extension %pV
Date: Tue, 20 Jul 2010 10:08:04 -0600
Message-ID: <201007201008.04496.bjorn.helgaas@hp.com>
References: <1279602367.19374.20.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Len Brown <lenb@kernel.org>, linux-acpi@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1279602367.19374.20.camel@Joe-Laptop.home>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, July 19, 2010 11:06:07 pm Joe Perches wrote:
> Consolidates the printk messages to a single
> call so the messages can not be interleaved.
> 
> Reduces text a bit.
> 
> $ size drivers/acpi/acpica/utmisc.o.*
>    text	   data	    bss	    dec	    hex	filename
>    7822	     56	   1832	   9710	   25ee	drivers/acpi/acpica/utmisc.o.old
>    7748	     56	   1736	   9540	   2544	drivers/acpi/acpica/utmisc.o.new
> 
> Depends on net-next commit 7db6f5fb65a82af03229eef104dc9899c5eecf33
> (vsprintf: Recursive vsnprintf: Add "%pV", struct va_format)

drivers/acpi/acpica/utmisc.c is part of the ACPI CA and is used in
several different OSes, but %pV sounds like a Linux-specific feature,
so I don't see how this patch can work.

Bjorn
