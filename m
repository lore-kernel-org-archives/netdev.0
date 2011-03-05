From: David Miller <davem@davemloft.net>
Subject: Re: FYI: tftp-hpa breaks when used on secondary ip addresses
Date: Fri, 04 Mar 2011 20:58:17 -0800 (PST)
Message-ID: <20110304.205817.193701195.davem@davemloft.net>
References: <m1sjv2qt68.fsf@fess.ebiederm.org>
	<4D719254.8000903@zytor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org, jsing@google.com
To: hpa@zytor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48731
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752444Ab1CEE5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 23:57:41 -0500
In-Reply-To: <4D719254.8000903@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "H. Peter Anvin" <hpa@zytor.com>
Date: Fri, 04 Mar 2011 17:31:00 -0800

> If this is done for all local connections (as opposed to the ones that
> have been configured explicitly by the administrator to behave that
> way), that's a massive lossage.  Not only does a large number of
> applications use this trick to determine if an address is local (e.g.
> allowing bypass) -- it is pretty much the only portable way to do it --
> but it would cause applications which expect to get a reply back from
> the same address they sent a request to to completely fall on their face.

Actually this is what SOL_IP, IP_PKTINFO, was created for.  Even glibc
uses it.
