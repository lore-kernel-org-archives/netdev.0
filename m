From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 08/27] HFI: DD request framework and first HFI DD
 request
Date: Thu, 21 Apr 2011 17:12:47 -0700 (PDT)
Message-ID: <20110421.171247.28810365.davem@davemloft.net>
References: <1303421937-2325-1-git-send-email-dykmanj@linux.vnet.ibm.com>
	<1303421937-2325-9-git-send-email-dykmanj@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, piyushc@linux.vnet.ibm.com,
	fcchang@linux.vnet.ibm.com, wscadden@linux.vnet.ibm.com,
	winstonc@linux.vnet.ibm.com, sakolish@linux.vnet.ibm.com,
	jian@linux.vnet.ibm.com, clsoto@linux.vnet.ibm.com,
	sjsheppa@linux.vnet.ibm.com
To: dykmanj@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40592
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751994Ab1DVANW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 20:13:22 -0400
In-Reply-To: <1303421937-2325-9-git-send-email-dykmanj@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: dykmanj@linux.vnet.ibm.com
Date: Thu, 21 Apr 2011 17:38:38 -0400

> +#include <linux/vermagic.h>

I think this has been brought up by others, but please do not include
kernel version headers in your driver.

Not only should it be completely unnecessary upstream, it also makes
your driver get rebuilt every single make of the tree, which drivers
some of us crazy :-)

Thanks.
