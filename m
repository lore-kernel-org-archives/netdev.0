From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 1/2] net: dsa: mv88e6352: Refactor shareable code
Date: Sun, 15 Feb 2015 19:09:42 -0800
Message-ID: <54E15F76.1020201@roeck-us.net>
References: <1423937871-9180-1-git-send-email-andrew@lunn.ch> <1423937871-9180-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:37460 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272AbbBPDJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 22:09:45 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YNC48-0048Cq-0H
	for netdev@vger.kernel.org; Mon, 16 Feb 2015 03:09:45 +0000
In-Reply-To: <1423937871-9180-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/14/2015 10:17 AM, Andrew Lunn wrote:
> The mv88e6352 allows access to the port phys via an internal mdio bus
> which is accessed using registers in the GLOBAL 2 range. The mv88e6171
> and probably other devices use the same mechanism. Move this code into
> the shared mv88e6xxx.c library.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

With mv88e6352:

Tested-by: Guenter Roeck <linux@roeck-us.net>

Guenter
