From: Jingoo Han <jg1.han@samsung.com>
Subject: Re: [PATCH 22/52] net: e100: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 17:52:41 +0900
Message-ID: <000701ceaecc$4655e9c0$d301bd40$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
 <006001ceaec2$f0ef0dd0$d2cd2970$%han@samsung.com>
 <1378888791.2026.2.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>, netdev@vger.kernel.org,
	'Aaron Brown' <aaron.f.brown@intel.com>,
	'Jingoo Han' <jg1.han@samsung.com>
To: 'Jeff Kirsher' <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:45152 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150Ab3IKIwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 04:52:47 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY00AJADZRWVZ0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 17:52:42 +0900 (KST)
In-reply-to: <1378888791.2026.2.camel@jtkirshe-mobl>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, September 11, 2013 5:40 PM, Jeff Kirsher wrote:
> On Wed, 2013-09-11 at 16:45 +0900, Jingoo Han wrote:
> > The driver core clears the driver data to NULL after device_release
> > or on probe failure. Thus, it is not needed to manually clear the
> > device driver data to NULL.
> >
> > Signed-off-by: Jingoo Han <jg1.han@samsung.com>
> > ---
> >  drivers/net/ethernet/intel/e100.c |    2 --
> >  1 file changed, 2 deletions(-)
> 
> While I do not find anything wrong with this patch, I personally like
> good housekeeping so I would like to keep the code as is.  Is there a
> reason for this patch?

Vice versa,
Is there any reason to keep unnecessary code?

Clearing drvdata is done by driver core, so each driver does not
need to clear drvdata.
This patch reduces code size and removes duplicated functional execution.

Please consider it positively. :-)

Best regards,
Jingoo Han
