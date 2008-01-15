From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25] [XFRM] Remove unused definition
 XFRM_POLICY_LOCALOK in linux/xfrm.h + typos in net/xfrm.h
Date: Tue, 15 Jan 2008 00:47:06 -0800 (PST)
Message-ID: <20080115.004706.107988820.davem@davemloft.net>
References: <eb3ff54b0801150017s425c2d10xe570cc70d2ca596b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39733
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751283AbYAOIrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 03:47:13 -0500
In-Reply-To: <eb3ff54b0801150017s425c2d10xe570cc70d2ca596b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Tue, 15 Jan 2008 10:17:37 +0200

> Hi,
> - XFRM_POLICY_LOCALOK in linux/xfrm.h is unused definition.
> - correct 4 typos in net/xfrm.h

Values in linux/xfrm.h are user visible, so I am worried that this
might break the build of some userland application.

Herbert explained that this value is unused inside of the
kernel, and that is true, but I'm not so sure that there
are no applications using the value.

We might have to keep it there.
