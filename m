From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: Faster TCP keepalive
Date: Mon, 26 Jun 2017 15:40:19 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD002B15F@AcuExch.aculab.com>
References: <20170623195817.GA13904@ssuryaputra-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Stephen Suryaputra Lin' <stephen.suryaputra.lin@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.192]:50277 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751366AbdFZPkY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2017 11:40:24 -0400
In-Reply-To: <20170623195817.GA13904@ssuryaputra-desktop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Stephen Suryaputra Lin
> Sent: 23 June 2017 20:58
...
> Suggestions on other ways to quickly tearing down TCP connections to a
> rebooted host in the application above are welcomed.

Arrange to send an RST for each connection during shutdown.

	David
