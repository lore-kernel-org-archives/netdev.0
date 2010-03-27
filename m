From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: use the appropriate namespace pid
Date: Fri, 26 Mar 2010 20:15:06 -0700 (PDT)
Message-ID: <20100326.201506.184725289.davem@davemloft.net>
References: <20100321.213022.22037430.davem@davemloft.net>
	<b6fcc0a1003240058i524c95eere17c1349d14267b1@mail.gmail.com>
	<6AFD35BEDB60334C9A31FD694E13EF0D226771E62E@XCH-NW-18V.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org, adobriyan@openvz.org
To: Thomas.Goff@boeing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44597
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751710Ab0C0DOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 23:14:42 -0400
In-Reply-To: <6AFD35BEDB60334C9A31FD694E13EF0D226771E62E@XCH-NW-18V.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Goff, Thomas" <Thomas.Goff@boeing.com>
Date: Wed, 24 Mar 2010 07:18:12 -0700

> On Wed March 24, 2010 12:59 AM, Alexey Dobriyan <adobriyan@gmail.com> wrote:
>> ACK tgid patch, should have sent it myself long ago.
> 
> Thanks for reviewing this.
> 
> David is correct that pid is arbitrary here anyway so it really
> shouldn't matter.  The patch just lets applications that make an
> incorrect assumption that happens to usually be right for the
> initial namespace work similarly in other namespaces.  So
> including the patch seems more of a policy question.

I ended up applying this to net-next-2.6, it's not critical
so it's not net-2.6 material, but it's harmless so we can
still queue it up for the next merge window.
