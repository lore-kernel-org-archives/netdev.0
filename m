From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: BCM5719(tg3) use multiple MSI with RSS
Date: Wed, 15 May 2013 08:08:58 -0700
Message-ID: <1368630538.3768.12.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <51933FCB.4090402@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, mcarlson@broadcom.com, zambrano@broadcom.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: "Mike Qiu" <qiudayu@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2855 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759182Ab3EOPJM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 May 2013 11:09:12 -0400
In-Reply-To: <51933FCB.4090402@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-15 at 15:56 +0800, Mike Qiu wrote: 
> Hi all
> 
> Currently, I need to enable multiple MSI on BCM5719 network card.
> But I look in to the spec of 5719 from Broadcom, it seems
> that RSS just enable with MSI-X, so I'm not sure if multiple
> MSI can use RSS.
> 

MSI can only support one IRQ source and cannot support RSS.
