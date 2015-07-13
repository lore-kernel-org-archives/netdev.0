From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: dsa: mv88e6xxx: add write access to debugfs
 regs file
Date: Sun, 12 Jul 2015 20:25:13 -0700 (PDT)
Message-ID: <20150712.202513.301354636371108143.davem@davemloft.net>
References: <1092744390.7730.1436639772848.JavaMail.zimbra@savoirfairelinux.com>
	<20150711.190822.1431177169987395247.davem@davemloft.net>
	<1788707459.58885.1436751570981.JavaMail.zimbra@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@roeck-us.net, andrew@lunn.ch,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38857 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751729AbbGMDZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2015 23:25:14 -0400
In-Reply-To: <1788707459.58885.1436751570981.JavaMail.zimbra@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Sun, 12 Jul 2015 21:39:30 -0400 (EDT)

> I hardly see how this debug interface can be made generic to other
> DSA drivers, since the format of hardware tables or some registers
> seem very specific to the switch chip.

You feel this way because you are focusing on register values and not what
those values represent.

Ie. could you export the values in those registers in a generic format
that other devices could convert their register values to as well?

Stop focusing so tightly on the exact thing you've implemented and
consider things on a much higher level.
