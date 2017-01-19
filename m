From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: Setting link down or up in software
Date: Thu, 19 Jan 2017 17:56:41 +0000
Message-ID: <yw1xbmv3j5ly.fsf@unicorn.mansr.com>
References: <75bd6df2-714a-2b9b-a0e3-f5574c295377@free.fr>
        <2044a26f-cf95-ac55-6265-ac76c3ca53f6@free.fr>
        <0273a4ad-46f7-d7b9-a206-6bd713e6165e@neratec.com>
        <9be9b48d-1bef-b48f-866f-8651d9b9c245@free.fr>
        <bfe5bd8b-d4eb-8c8e-45d8-6ea1c133b4a7@neratec.com>
        <660b7b17-0136-bf69-fd12-1c125069829b@free.fr>
        <dc6378d7-d370-c893-63b7-c21cd7ef76fd@neratec.com>
        <1ac88f50-30c5-fbaf-11ff-2d42490b5801@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:41066 "EHLO unicorn.mansr.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753924AbdASSVm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 13:21:42 -0500
In-Reply-To: <1ac88f50-30c5-fbaf-11ff-2d42490b5801@free.fr> (Mason's message
        of "Thu, 19 Jan 2017 16:40:04 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mason <slash.tmp@free.fr> writes:

> One thing I find confusing... If the 8035 could work with the generic
> PHY driver, what's the point of the at803x.ko driver?

Almost all Ethernet PHYs support the basic operation defined the by the
standard.  Many have additional non-standardised features that require a
specific driver.  Interrupts, for example.

-- 
Måns Rullgård
