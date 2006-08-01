From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] sunlance: fix compilation on sparc-UP
Date: Wed, 2 Aug 2006 03:31:35 +0400
Message-ID: <20060801233135.GA23567@martell.zuzino.mipt.ru>
References: <20060727093520.GA6825@martell.zuzino.mipt.ru> <20060728.010949.75429893.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:25651 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1750721AbWHAXbj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 19:31:39 -0400
Received: by ug-out-1314.google.com with SMTP id m3so4465ugc
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2006 16:31:38 -0700 (PDT)
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060728.010949.75429893.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

FYI, drivers/scsi/esp.c was broken by same changes.

drivers/scsi/esp.c: In function `esp_sun4_probe':
drivers/scsi/esp.c:1149: error: `esp_dev' undeclared (first use in this function)
drivers/scsi/esp.c:1149: error: (Each undeclared identifier is reported only once
drivers/scsi/esp.c:1149: error: for each function it appears in.)
drivers/scsi/esp.c: In function `esp_sun4_remove':
drivers/scsi/esp.c:1165: error: `dev' undeclared (first use in this function)

First is trivial. The question is what to pass to esp_sun4_remove()?
/me no expert.

