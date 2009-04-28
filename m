From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rio: warn_unused_result warnings fix
Date: Tue, 28 Apr 2009 04:38:23 -0700 (PDT)
Message-ID: <20090428.043823.244762395.davem@davemloft.net>
References: <1240913737-23773-5-git-send-email-leoli@freescale.com>
	<1240915882.15414.3.camel@localhost>
	<2a27d3730904280408j636d8e4tc1b6e1c827509379@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michael@ellerman.id.au, akpm@linux-foundation.org,
	galak@kernel.crashing.org, mporter@kernel.crashing.org,
	linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: leoli@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33021
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755126AbZD1Li3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 07:38:29 -0400
In-Reply-To: <2a27d3730904280408j636d8e4tc1b6e1c827509379@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Yang <leoli@freescale.com>
Date: Tue, 28 Apr 2009 19:08:13 +0800

> IMHO, when device_add() fails the system is quite broken.  So the
> value is very limited for it to fail cleanly, which need some effort
> to implement.  I can add it if you insist.

I disagree.

For the cases where device_add() fails (duplicate name, for
example) the device layer already is emitting warnings.

You're just adding more log messages for the user to sift
through, and likely not adding any new information.
