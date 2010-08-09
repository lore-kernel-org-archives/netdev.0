From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: fix a possible leak of dev reference count.
Date: Sun, 08 Aug 2010 20:17:17 -0700 (PDT)
Message-ID: <20100808.201717.133866941.davem@davemloft.net>
References: <AANLkTi==t8MGGLDxMLZsHtRoLqwhgNskU83wBw7-+ZyJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, error27@gmail.com
To: kzjeef@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35283
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755266Ab0HIDQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Aug 2010 23:16:57 -0400
In-Reply-To: <AANLkTi==t8MGGLDxMLZsHtRoLqwhgNskU83wBw7-+ZyJ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang JieJing <kzjeef@gmail.com>
Date: Sun, 8 Aug 2010 21:34:12 +0800

> call dev_put(dev) on error path.
> 
> Signed-off-by: JieJing.Zhang <kzjeef@gmail.com>

There is no leak, the caller will dst_free() the dst and at
such time the device at dst->dev will be released.
