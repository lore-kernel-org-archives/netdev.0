From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Setting link down or up in software
Date: Thu, 12 Jan 2017 17:27:34 +0100
Message-ID: <20170112162734.GB10203@lunn.ch>
References: <75bd6df2-714a-2b9b-a0e3-f5574c295377@free.fr>
 <2044a26f-cf95-ac55-6265-ac76c3ca53f6@free.fr>
 <20170112152856.GL13033@lunn.ch>
 <75281de4-d50d-76fd-8de9-606001a4d93a@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Mans Rullgard <mans@mansr.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58499 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750899AbdALQ1g (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 11:27:36 -0500
Content-Disposition: inline
In-Reply-To: <75281de4-d50d-76fd-8de9-606001a4d93a@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Whatever the reason for the symptoms I'm seeing, some kind of race
> condition must be involved, because it occurs randomly.

The PHY is polled once a second for its status. So it would depend on
who fast autoneg happens if you see the down.

	Andrew
