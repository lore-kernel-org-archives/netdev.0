From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH 3/7] net: vmxnet3: remove unnecessary pci_set_drvdata()
Date: Mon, 9 Dec 2013 20:37:29 -0800 (PST)
Message-ID: <138955249.12889474.1386650249416.JavaMail.root@vmware.com>
References: <000601cef55a$b605fab0$2211f010$%han@samsung.com> <000d01cef55a$ebbfa430$c33eec90$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	pv-drivers@vmware.com, Andy King <acking@vmware.com>,
	Aditya Sarwade <asarwade@vmware.com>,
	George Zhang <georgezhang@vmware.com>
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([208.91.2.12]:36403 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750751Ab3LJEha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 23:37:30 -0500
In-Reply-To: <000d01cef55a$ebbfa430$c33eec90$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The driver core clears the driver data to NULL after device_release
> or on probe failure. Thus, it is not needed to manually clear the
> device driver data to NULL.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
