From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: RE: [PATCH net 5/5] bnx2x: fix VLAN configuration for VFs.
Date: Sun, 5 Jan 2014 19:24:27 +0000
Message-ID: <979A8436335E3744ADCD3A9F2A2B68A52AF22CDE@SJEXCHMB10.corp.ad.broadcom.com>
References: <1388939634-19948-1-git-send-email-yuvalmin@broadcom.com>
	<1388939634-19948-6-git-send-email-yuvalmin@broadcom.com>
 <CAJZOPZJ7NQZspnNksr=w9Yo1MtgstLhVbqwxUWE0k+tbhCaO4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ariel Elior <ariele@broadcom.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:12289 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbaAETY2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 14:24:28 -0500
In-Reply-To: <CAJZOPZJ7NQZspnNksr=w9Yo1MtgstLhVbqwxUWE0k+tbhCaO4g@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Sun, Jan 5, 2014 at 6:33 PM, Yuval Mintz <yuvalmin@broadcom.com>
> wrote:
> > If the hypervisor configures a vlan for the VF via the PF, the expected
> > result is that only packets tagged by said vlan will be received by the VF
> > (and that vlan will be silently removed).
> > Do to an incorrect manipulation of vlan filters in the driver, the
> 
> Did you want to say "Due to an incorrect"?

Yeps... Typo, obviously.

> 
> > VF can receive untagged traffic even if the hypervisor configured
> > some vlan for it.
