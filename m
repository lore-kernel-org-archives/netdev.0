From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 0/5][SYSCTL]: Make some sysctl RO in net
 namespaces.
Date: Tue, 26 Feb 2008 23:10:44 -0800 (PST)
Message-ID: <20080226.231044.132522648.davem@davemloft.net>
References: <47BAC38F.10100@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38085
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754345AbYB0HKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 02:10:44 -0500
In-Reply-To: <47BAC38F.10100@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 19 Feb 2008 14:54:55 +0300

> So, here's the patchset, that allows to create ctl tables, that are
> read-only in some namespace in general (and in some net namespace in 
> particular). I tried to make it work the way not to consume extra
> memory at run time.

These changes look great.

> This patchset is related to net namespaces only, but on the other hand
> it affects the core sysctl engine. What is your opinion about this set:
> should I send these patches (or some of them) to Andrew instead and wait 
> till it appears in mainline (and sequentially in net tree) or will you
> accept this one in net-2.6.26?

What we should do is get patches 1-3 reviewed on linux-kernel and then
into linux-next somehow (perhaps there is some FS tree?).

Once that happens, I can get net-2.6.26 going and put patch 4 and 5 in
there.

Thanks!
