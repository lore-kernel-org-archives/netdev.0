From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 10/12] nfp: fix print format for ring pointers
 in ring dumps
Date: Wed, 31 May 2017 10:33:50 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0005B27@AcuExch.aculab.com>
References: <20170528003411.17603-1-jakub.kicinski@netronome.com>
 <20170528003411.17603-11-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "oss-drivers@netronome.com" <oss-drivers@netronome.com>
To: 'Jakub Kicinski' <jakub.kicinski@netronome.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.192]:56450 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751136AbdEaKdz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 06:33:55 -0400
In-Reply-To: <20170528003411.17603-11-jakub.kicinski@netronome.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski
> Sent: 28 May 2017 01:34
> Ring pointers are unsigned.  Fix the print formats to avoid
> showing users negative values.
...
> 
> -	seq_printf(file, "RX[%02d,%02d]: cnt=%d dma=%pad host=%p   H_RD=%d H_WR=%d FL_RD=%d FL_WR=%d\n",
> +	seq_printf(file, "RX[%02d,%02d]: cnt=%u dma=%pad host=%p   H_RD=%u H_WR=%u FL_RD=%u FL_WR=%u\n",

I can't help feeling that %x might be better here.
The wrap points and ring full conditions will be rather more obvious.

	David
