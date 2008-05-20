From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] [NET] The world is not perfect patch.
Date: Tue, 20 May 2008 14:33:21 -0700 (PDT)
Message-ID: <20080520.143321.97817925.davem@davemloft.net>
References: <eb3ff54b0805200229r6fb2daa1w50aaffa9b130f89f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43362
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760397AbYETVd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 17:33:26 -0400
In-Reply-To: <eb3ff54b0805200229r6fb2daa1w50aaffa9b130f89f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Tue, 20 May 2008 12:29:26 +0300

> There are three methods in the network stack which start with
> #ifndef I_WISH_WORLD_WERE_PERFECT.

I think it is better to delete this code.  It is impossible
for anyone to build test it without making source modifications,
therefore it will continute to break over and over again over
time.
