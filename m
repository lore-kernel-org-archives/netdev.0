From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH V2] e1000:  Add netif_napi_del in the normal path and
 error path to match netif_napi_add
Date: Sun, 21 Dec 2014 16:57:59 +0300
Message-ID: <5496D1E7.5060908@cogentembedded.com>
References: <000201d01c61$bdb956b0$392c0410$@163.com> <20141220.143005.1130435723139487537.davem@davemloft.net> <549619E6.8070503@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: todd.fujinaka@intel.com, Linux-nics@isotope.jf.intel.com,
	linux.nics@intel.com, e1000-devel@lists.sourceforge.net
To: Jia-Ju Bai <baijiaju1990@163.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:35263 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753441AbaLUN6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2014 08:58:01 -0500
Received: by mail-lb0-f174.google.com with SMTP id 10so2864846lbg.33
        for <netdev@vger.kernel.org>; Sun, 21 Dec 2014 05:58:00 -0800 (PST)
In-Reply-To: <549619E6.8070503@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/21/2014 3:52 AM, Jia-Ju Bai wrote:

> Th driver lacks netif_napi_del in the normal path and error path to match the
> call of netif_napi_add in e1000_probe.

    Please wrap your change log lines at 80 columns (or less).

> This patch fixes this problem, and it has been tested in runtime.

> Signed-off-by: Jia-Ju Bai<baijiaju1990@163.com>

> ---

>   drivers/net/ethernet/intel/e1000/e1000_main.c    |    6 +-

>   1 file changed, 4 insertions(+), 2 deletions(-)

> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c
> b/drivers/net/ethernet/intel/e1000/e1000_main.c
>
> index 24f3986..f6def7b 100644
>
> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
>
> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
>
> @@ -1004,7 +1004,7 @@ static int e1000_probe(struct pci_dev *pdev, const
> struct pci_device_id *ent)
>
>       /* make ready for any if (hw->...) below */
>
>       err = e1000_init_hw_struct(adapter, hw);
>
>       if (err)
>
> -        goto err_sw_init;
>
> +        goto err_dma;
>
>       /* there is a workaround being applied below that limits
>
>       * 64-bit DMA addresses to 64-bit hardware.  There are some

    Somehow your mailer inserted empty lines after each actual line of the 
patch. :-(

WBR, Sergei
