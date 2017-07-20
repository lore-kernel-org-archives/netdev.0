From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH 2/2] net: ethernet: nb8800: Fix RGMII TX clock delay setup
Date: Thu, 20 Jul 2017 13:39:33 +0100
Message-ID: <yw1xmv7zqo3e.fsf@mansr.com>
References: <b332dc3e-4478-e34b-2b3f-226aad8a11d4@sigmadesigns.com>
        <61b71d12-4e3a-edbe-1d69-c66e7cf46d8e@sigmadesigns.com>
        <yw1xzic0qrcg.fsf@mansr.com>
        <001a7afd-364d-359e-1478-e057c9083f73@free.fr>
        <d8121f82-dffd-22c7-1209-a3c2329703e5@gmail.com>
        <05cbc32e-a4af-1c81-128b-bc5d2206d24a@free.fr>
        <bf484952-15ae-b385-6b54-4d07b3bc2b29@gmail.com>
        <54f5bd21-766d-d9de-3b15-a01fd5ee6035@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Timur Tabi <timur@codeaurora.org>,
        Daniel Mack <zonque@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        "David S. Miller" <davem@davemloft.net>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:34504 "EHLO unicorn.mansr.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934643AbdGTMjg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Jul 2017 08:39:36 -0400
In-Reply-To: <54f5bd21-766d-d9de-3b15-a01fd5ee6035@free.fr> (Mason's message
        of "Thu, 20 Jul 2017 14:33:00 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mason <slash.tmp@free.fr> writes:

> I will look for an inter-packet gap knob and FCS error counter.

There is an FCS error counter.  Use "ethtool -S" and look for
rx_bad_fcs_frames.  Reading the stats counters automatically resets
them to zero.

-- 
Måns Rullgård
