From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: bcm_sf2: Implement FDB operations
Date: Mon, 06 Jun 2016 09:30:29 -0400
Message-ID: <87r3cajvgq.fsf@ketchup.mtl.sfl>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com> <1464998733-10405-4-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, andrew@lunn.ch, john@phrozen.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:60141 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbcFFNad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 09:30:33 -0400
In-Reply-To: <1464998733-10405-4-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> Add support for the FDB add, delete, and dump operations. The add and
> delete operations are implemented using directed ARL operations using
> the specified MAC address and consist in a read operation, write and
> readback operation.
>
> The dump operation consists in using the ARL search and software
> filtering entries which are not for the desired port.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
