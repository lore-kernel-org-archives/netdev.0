From: Stephen Hemminger <shemminger@osdl.org>
Subject: forcedeth driver NAPI?
Date: Tue, 2 May 2006 12:11:51 -0700
Message-ID: <20060502121151.63786a86@localhost.localdomain>
References: <200605021549.47719.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:42888 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750749AbWEBTMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 May 2006 15:12:05 -0400
To: Ingo Oeser <netdev@axxeo.de>
In-Reply-To: <200605021549.47719.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Has anyone looked into making this driver use NAPI?  This would fix
the IRQ overload problem and a number of other DoS risks.
Also, if done right the device lock could be reduced to just
a transmit lock.
