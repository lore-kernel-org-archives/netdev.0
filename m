From: David Miller <davem@davemloft.net>
Subject: Re: VLAN patch: Export symbols as non GPL symbols.
Date: Mon, 26 Jan 2009 12:37:59 -0800 (PST)
Message-ID: <20090126.123759.25767520.davem@davemloft.net>
References: <497DEC7A.1040405@candelatech.com>
	<497DED71.50900@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59151
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751470AbZAZUh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 15:37:57 -0500
In-Reply-To: <497DED71.50900@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 26 Jan 2009 18:05:53 +0100

> Ben Greear wrote:
> > In previous kernels, any kernel module could get access to the 'real-device' and the
> > VLAN-ID for a particular VLAN.  In more recent kernels, the code was restructured
> > such that this is hard to do without accessing private .h files for any module that cannot
> > use GPL-only symbols.
> > Attached is a patch to once again allow non-GPL modules the ability to access the
> > real-device and VLAN id for VLANs.  This patch is against 2.6.29-rc2.
> > Signed-Off-By:  Ben Greear<greearb@candelatech.com>
> 
> I added that export after moving the code from a header file, but
> there's no reason from my side not to export this to non-GPLed
> drivers, using _GPL was merely a habit.
> 
> Acked-by: Patrick McHardy <kaber@trash.net>

Applied, thanks.
