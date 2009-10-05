From: Stefano Babic <stefano.babic@babic.homelinux.org>
Subject: Re: [5/8,RFC] CAIF Protocol Stack
Date: Mon, 05 Oct 2009 17:16:07 +0200
Message-ID: <4ACA0DB7.5000802@babic.homelinux.org>
References: <1253727086-10353-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Kim.xx.Lilliestierna@ericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout27.attiva.biz ([85.37.16.28]:64941 "EHLO
	smtpout27.attiva.biz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753055AbZJEPQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 11:16:50 -0400
In-Reply-To: <1253727086-10353-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sjur.brandeland@stericsson.com wrote:
> From: Kim Lilliestierna <Kim.xx.Lilliestierna@ericsson.com>
> 
> Signed-off-by: sjur.brandeland@stericsson.com

Hi Sjur,

> +obj-$(CAIF_CHRDEV) += chnl_chr.o

Probably this should be obj-$(CONFIG_CAIF_CHARDEV) += chnl_chr.o

> +
> +# Net device
> +obj-$(CAIF_NETDEV) += chnl_net.o

Should be maybe CONFIG_CAIF_NETDEV ?

Stefano

-- 
stefano <stefano.babic@babic.homelinux.org>
GPG Key: 0x55814DDE
Fingerprint 4E85 2A66 4CBA 497A 2A7B D3BF 5973 F216 5581 4DDE
