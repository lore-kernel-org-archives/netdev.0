From: Jingoo Han <jg1.han@samsung.com>
Subject: Re: [PATCH 3/7] net: vmxnet3: remove unnecessary pci_set_drvdata()
Date: Tue, 10 Dec 2013 13:53:51 +0900
Message-ID: <000001cef563$d2638cf0$772aa6d0$%han@samsung.com>
References: <000601cef55a$b605fab0$2211f010$%han@samsung.com>
 <000d01cef55a$ebbfa430$c33eec90$%han@samsung.com>
 <138955249.12889474.1386650249416.JavaMail.root@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>, netdev@vger.kernel.org,
	pv-drivers@vmware.com, 'Andy King' <acking@vmware.com>,
	'Aditya Sarwade' <asarwade@vmware.com>,
	'George Zhang' <georgezhang@vmware.com>,
	'Dmitry Torokhov' <dtor@vmware.com>,
	'Jingoo Han' <jg1.han@samsung.com>
To: 'Shreyas Bhatewara' <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:23577 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742Ab3LJExx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 23:53:53 -0500
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MXK005QXQXSXWD0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Tue, 10 Dec 2013 13:53:52 +0900 (KST)
In-reply-to: <138955249.12889474.1386650249416.JavaMail.root@vmware.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, December 10, 2013 1:37 PM, Shreyas Bhatewara wrote:
> On Monday, November 25, 2013 11:05:23 AM Jingoo Han wrote:
> > The driver core clears the driver data to NULL after device_release
> > or on probe failure. Thus, it is not needed to manually clear the
> > device driver data to NULL.
> >
> > Signed-off-by: Jingoo Han <jg1.han@samsung.com>
> 
> Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>

(+cc Dmitry Torokhov)

Hi Shreyas Bhatewara,

It may be 'Acked-by' instead of 'Signed-off-by', right?

Also, I missed 'Acked-by' from Dmitry Torokhov.
Acked-by: Dmitry Torokhov <dtor@vmware.com>

So, Dmitry Torokhov's 'Acked-by' should be added,
when this commit is merged.

Thank you for your feedback. :-)

Best regards,
Jingoo Han
