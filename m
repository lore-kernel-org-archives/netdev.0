From: David Miller <davem@davemloft.net>
Subject: Re: [TCP]: Fix shrinking windows with window scaling
Date: Thu, 20 Mar 2008 16:12:30 -0700 (PDT)
Message-ID: <20080320.161230.57609775.davem@davemloft.net>
References: <47DAB90E.40806@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41858
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753776AbYCTXMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 19:12:17 -0400
In-Reply-To: <47DAB90E.40806@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 14 Mar 2008 18:42:38 +0100

> Please review carefully since I'm not too familiar with the
> TCP code.

It looks perfect, excellent catch Patrick!

Applied, and I'll queue this up for -stable.

This bug has existed forever :(
