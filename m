From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net] hyperv: Fix the carrier status setting
Date: Mon, 10 Feb 2014 15:57:12 +0000
Message-ID: <191b34a54dad423c875c05f084cb1021@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1391994478-25809-1-git-send-email-haiyangz@microsoft.com>
 <20140210090359.GQ26722@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na01-by1-obe.ptr.o365filtering.com ([64.4.22.89]:9288 "EHLO
	na01-by1-obe.outbound.o365filtering.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751831AbaBJP5r convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Feb 2014 10:57:47 -0500
In-Reply-To: <20140210090359.GQ26722@mwanda>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Dan Carpenter [mailto:dan.carpenter@oracle.com]
> Sent: Monday, February 10, 2014 4:04 AM
> To: Haiyang Zhang
> Cc: davem@davemloft.net; netdev@vger.kernel.org; olaf@aepfle.de;
> jasowang@redhat.com; driverdev-devel@linuxdriverproject.org; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCH net] hyperv: Fix the carrier status setting
> 
> On Sun, Feb 09, 2014 at 05:07:58PM -0800, Haiyang Zhang wrote:
> > Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> > Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> 
> Changelog sucks.  What are the user visible effects of this bug?
> 
Without this patch, the "cat /sys/class/net/ethN/operstate" shows 
"unknown", and "ethtool ethN" shows "Link detected: yes", when VM
boots up with or without vNIC connected. This patch fixed the problem.

I will include the comments.

Thanks,
- Haiyang
