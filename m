From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] cxgb4: add new T6 pci device id's
Date: Mon, 19 Jun 2017 12:48:46 +0300
Message-ID: <912f67f7-0bee-b4f4-73c6-6eebf80652cf@cogentembedded.com>
References: <1497855249-7173-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nirranjan@chelsio.com, indranil@chelsio.com, venkatesh@chelsio.com
To: Ganesh Goudar <ganeshgr@chelsio.com>, netdev@vger.kernel.org,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:33415 "EHLO
        mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753807AbdFSJsq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 05:48:46 -0400
Received: by mail-lf0-f42.google.com with SMTP id m77so51953440lfe.0
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 02:48:45 -0700 (PDT)
In-Reply-To: <1497855249-7173-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 6/19/2017 9:54 AM, Ganesh Goudar wrote:

> Add 0x6081, 0x6082 and 0x6083 T6 device id's

    0x6081 is already there, you're adding 0x6084 instead.

> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
> ---
>  drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
> index be7041f..99987d8 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
> +++ b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
> @@ -192,6 +192,9 @@ CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
>  	CH_PCI_ID_TABLE_FENTRY(0x6015),
>  	CH_PCI_ID_TABLE_FENTRY(0x6080),
>  	CH_PCI_ID_TABLE_FENTRY(0x6081),
> +	CH_PCI_ID_TABLE_FENTRY(0x6082), /* Custom T6225-CR SFP28 */
> +	CH_PCI_ID_TABLE_FENTRY(0x6083), /* Custom T62100-CR QSFP28 */
> +	CH_PCI_ID_TABLE_FENTRY(0x6084), /* Custom T64100-CR QSFP28 */
>  CH_PCI_DEVICE_ID_TABLE_DEFINE_END;
>
>  #endif /* __T4_PCI_ID_TBL_H__ */

MBR, Sergei
