From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3 : avoid an expensive divide
Date: Tue, 06 Feb 2007 13:27:45 -0800 (PST)
Message-ID: <20070206.132745.76771836.davem@davemloft.net>
References: <45C8EAC4.9020803@cosmosbay.com>
	<20070206.131908.13769204.davem@davemloft.net>
	<1170799756.3535.27.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49647
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752110AbXBFV2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 16:28:11 -0500
In-Reply-To: <1170799756.3535.27.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 06 Feb 2007 14:09:16 -0800

> No objections.  I will create another patch to convert similar divisions
> in other spots.

I actually checked and those cases work on true constants so do not
generate the divide instructions.
