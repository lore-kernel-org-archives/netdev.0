From: Jens Rosenboom <jens@mcbone.net>
Subject: Re: [PATCH,v2] Re: e1000e: why does
 pci_enable_pcie_error_reporting() fail on my hp2510p?
Date: Fri, 21 Aug 2009 09:06:12 +0200
Message-ID: <1250838372.9489.8.camel@fnki-nb00130>
References: <200908201714.30638.elendil@planet.nl>
	 <200908210829.10471.elendil@planet.nl> <4A8E3FC1.50201@redhat.com>
	 <200908210848.39377.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Danny Feng <dfeng@redhat.com>, Netdev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
To: Frans Pop <elendil@planet.nl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754970AbZHUHGW@vger.kernel.org>
In-Reply-To: <200908210848.39377.elendil@planet.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-08-21 at 08:48 +0200, Frans Pop wrote:
[...]
> @@ -5301,9 +5296,6 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
>  
>  	/* AER disable */
>  	err = pci_disable_pcie_error_reporting(pdev);
> -	if (err)
> -		dev_err(&pdev->dev,
> -		        "pci_disable_pcie_error_reporting failed 0x%x\n", err);
>  
>  	pci_disable_device(pdev);
>  }

While you're at it, why don't you also remove the "err =" here, which
allows you to drop the variable from that function completely? This
applies to all three *_remove() functions.
