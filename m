From: Timur Tabi <timur.tabi@calxeda.com>
Subject: Re: [PATCH v2] net: fec_mpc52xx: Read MAC address from device-tree
Date: Tue, 12 Feb 2013 06:36:55 -0600
Message-ID: <CAOZdJXUjxLd_Zds4e6faWuomG6_p6FE1YfnCDmQD-BvY86i2Mw@mail.gmail.com>
References: <1360660088-27464-1-git-send-email-sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Anatolij Gustschin <agust@denx.de>
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp141.iad.emailsrvr.com ([207.97.245.141]:47379 "EHLO
	smtp141.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932967Ab3BLMqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 07:46:33 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by smtp24.relay.iad1a.emailsrvr.com (SMTP Server) with ESMTP id EE0DC1A0555
	for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 07:36:57 -0500 (EST)
Received: by smtp24.relay.iad1a.emailsrvr.com (Authenticated sender: timur.tabi-AT-calxeda.com) with ESMTPSA id A2FF61A04F8
	for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 07:36:57 -0500 (EST)
Received: by mail-la0-f49.google.com with SMTP id fs13so20956lab.36
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 04:36:56 -0800 (PST)
In-Reply-To: <1360660088-27464-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 12, 2013 at 3:08 AM, Stefan Roese <sr@denx.de> wrote:

> +        * First try to read MAC address from DT
> +        */
> +       p = of_get_property(np, "local-mac-address", NULL);

of_get_mac_address()
