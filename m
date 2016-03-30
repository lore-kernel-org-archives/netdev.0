From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v3 2/2] net: dsa: mv88e6xxx: Clear the PDOWN bit on setup
Date: Wed, 30 Mar 2016 10:10:46 -0400
Message-ID: <8737r8cazd.fsf@ketchup.mtl.sfl>
References: <1459301981-26535-1-git-send-email-patrick@puiterwijk.org> <1459301981-26535-2-git-send-email-patrick@puiterwijk.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, dennis@ausil.us, pbrobinson@gmail.com,
	Patrick Uiterwijk <patrick@puiterwijk.org>,
	Kevin Smith <kevin.smith@elecsyscorp.com>,
	Lucile Quirion <lucile.quirion@savoirfairelinux.com>
To: Patrick Uiterwijk <patrick@puiterwijk.org>, linux@roeck-us.net,
	davem@davemloft.net, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:43264 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754010AbcC3OKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 10:10:53 -0400
In-Reply-To: <1459301981-26535-2-git-send-email-patrick@puiterwijk.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick Uiterwijk <patrick@puiterwijk.org> writes:

> Some of the vendor-specific bootloaders set up this part
> of the initialization for us, so this was never added.
> However, since upstream bootloaders don't initialize the
> chip specifically, they leave the fiber MII's PDOWN flag
> set, which means that the CPU port doesn't connect.
>
> This patch checks whether this flag has been clear prior
> by something else, and if not make us clear it.
>
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Patrick Uiterwijk <patrick@puiterwijk.org>

Tested-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

This fixes the SerDes link on my single 6352 x86 platform.

Thanks!
Vivien
