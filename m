From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next,v4] hyperv: Add support for virtual Receive
 Side Scaling (vRSS)
Date: Tue, 25 Mar 2014 20:37:43 +0000
Message-ID: <216cd74854414cfc9b338cab41a3d1a0@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1395434633-16771-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: KY Srinivasan <kys@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>
To: Haiyang Zhang <haiyangz@microsoft.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na01-by1-obe.ptr.o365filtering.com ([64.4.22.87]:2154 "EHLO
	na01-by1-obe.outbound.o365filtering.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755121AbaCYUid convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2014 16:38:33 -0400
In-Reply-To: <1395434633-16771-1-git-send-email-haiyangz@microsoft.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Haiyang Zhang [mailto:haiyangz@microsoft.com]
> Sent: Friday, March 21, 2014 4:44 PM
> To: davem@davemloft.net; netdev@vger.kernel.org
> Cc: Haiyang Zhang; KY Srinivasan; olaf@aepfle.de; jasowang@redhat.com;
> linux-kernel@vger.kernel.org; driverdev-devel@linuxdriverproject.org
> Subject: [PATCH net-next,v4] hyperv: Add support for virtual Receive
> Side Scaling (vRSS)
> 
> This feature allows multiple channels to be used by each virtual NIC.
> It is available on Hyper-V host 2012 R2.
> 
> (It depends on this commit:
> Drivers: hv: vmbus: Support per-channel driver state
> http://git.kernel.org/cgit/linux/kernel/git/next/linux-
> next.git/commit/?id=8a7206a89f85c8439561b0eff85bb9440a2e97a9
> )

Hi Dave,

Do we know when the dependency (commit: 8a7206a89f) will be merged
into net-next tree?

Thanks,
- Haiyang
