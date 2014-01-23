From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: RE: [PATCH net] bnx2x: Fix VF flr flow
Date: Thu, 23 Jan 2014 11:26:56 +0000
Message-ID: <979A8436335E3744ADCD3A9F2A2B68A52AF2AB96@SJEXCHMB10.corp.ad.broadcom.com>
References: <1390293080-21276-1-git-send-email-yuvalmin@broadcom.com>
 <20140121.231326.564835234426557051.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ariel Elior <ariele@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:8137 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099AbaAWL05 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 06:26:57 -0500
In-Reply-To: <20140121.231326.564835234426557051.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > When a VF originating from a given PF is flr-ed, that PF gets an interrupt
> > from the chip management and takes a part in the flr process.
> >
> > This patch fixes several corner cases in which the driver performs its part
> > of the flr flow out-of-order, causing the FW to assert due to badly timed
> > messages received from the driver.
> >
> > Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> > Signed-off-by: Ariel Elior <ariele@broadcom.com>
> 
> Applied.

Hi Dave,

Pulled `net' but I still can't see the fix there.

Thanks,
Yuval
