From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 3/8] net: qualcomm: move qcaspi_tx_cmd to
 qca_spi.c
Date: Tue, 18 Oct 2016 14:28:13 -0400 (EDT)
Message-ID: <20161018.142813.519636152972010259.davem@davemloft.net>
References: <1476790054-27174-1-git-send-email-stefan.wahren@i2se.com>
        <1476790054-27174-4-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, jslaby@suse.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: stefan.wahren@i2se.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45248 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932176AbcJRS2O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 14:28:14 -0400
In-Reply-To: <1476790054-27174-4-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Wahren <stefan.wahren@i2se.com>
Date: Tue, 18 Oct 2016 13:27:29 +0200

> diff --git a/drivers/net/ethernet/qualcomm/qca_7k.h b/drivers/net/ethernet/qualcomm/qca_7k.h
> index 1cad851..b390b1f 100644
> --- a/drivers/net/ethernet/qualcomm/qca_7k.h
> +++ b/drivers/net/ethernet/qualcomm/qca_7k.h
> @@ -67,6 +67,5 @@
>  void qcaspi_spi_error(struct qcaspi *qca);
>  int qcaspi_read_register(struct qcaspi *qca, u16 reg, u16 *result);
>  int qcaspi_write_register(struct qcaspi *qca, u16 reg, u16 value);
> -int qcaspi_tx_cmd(struct qcaspi *qca, u16 cmd);
>  
>  #endif /* _QCA_7K_H */
> diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
> index 6e2add9..5bcac62 100644
> --- a/drivers/net/ethernet/qualcomm/qca_spi.c
> +++ b/drivers/net/ethernet/qualcomm/qca_spi.c
> @@ -192,6 +192,30 @@ qcaspi_read_legacy(struct qcaspi *qca, u8 *dst, u32 len)
>  	return len;
>  }
>  
> +int
> +qcaspi_tx_cmd(struct qcaspi *qca, u16 cmd)
> +{

If you do this then you must mark this function 'static'.
