From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pch_gbe: Fix the issue that the receiving data is not
 normal.
Date: Tue, 08 Feb 2011 16:35:22 -0800 (PST)
Message-ID: <20110208.163522.232741523.davem@davemloft.net>
References: <4D50FDAA.1060506@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qi.wang@intel.com, yong.y.wang@intel.com,
	andrew.chih.howe.khor@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, tomoya-linux@dsn.okisemi.com
To: toshiharu-linux@dsn.okisemi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D50FDAA.1060506@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Date: Tue, 08 Feb 2011 17:24:10 +0900

> Hi Devid
> 
> I resubmit this patch modified.
> Please check them.

Your memcpy+memcpy sequences are equivalent to memmove(), please
use that instead.

I have to say this function is insanely complicated.  There seems
to be 16 different ways RX packets are processed.  I can't believe
that is needs to be like this.
