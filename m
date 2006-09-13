From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 4/12] smc911x: PRINT_PKT doesnt count on odd remainder
Date: Wed, 13 Sep 2006 21:01:52 +0200
Message-ID: <20060913190152.GB25007@electric-eye.fr.zoreil.com>
References: <200609132054.06704.bora.sahin@ttnet.net.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Dustin McIntire <dustin@sensoria.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:19340 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751119AbWIMTFK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 15:05:10 -0400
To: bora.sahin@ttnet.net.tr
Content-Disposition: inline
In-Reply-To: <200609132054.06704.bora.sahin@ttnet.net.tr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bora.sahin@ttnet.net.tr <bora.sahin@ttnet.net.tr> :
[...]
> @@ -202,6 +202,7 @@
>  		b = *buf++;
>  		printk("%02x%02x ", a, b);
>  	}
> +	if (remainder & 1) printk("%02x", *buf);

printk should be on the next line.

-- 
Ueimor
