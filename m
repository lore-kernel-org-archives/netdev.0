From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Setting link down or up in software
Date: Thu, 19 Jan 2017 09:59:20 -0800
Message-ID: <027dabb7-62fb-88bf-f51e-26fdc728d85f@gmail.com>
References: <75bd6df2-714a-2b9b-a0e3-f5574c295377@free.fr>
 <2044a26f-cf95-ac55-6265-ac76c3ca53f6@free.fr>
 <0273a4ad-46f7-d7b9-a206-6bd713e6165e@neratec.com>
 <9be9b48d-1bef-b48f-866f-8651d9b9c245@free.fr>
 <bfe5bd8b-d4eb-8c8e-45d8-6ea1c133b4a7@neratec.com>
 <660b7b17-0136-bf69-fd12-1c125069829b@free.fr>
 <dc6378d7-d370-c893-63b7-c21cd7ef76fd@neratec.com>
 <1ac88f50-30c5-fbaf-11ff-2d42490b5801@free.fr>
 <yw1xbmv3j5ly.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: =?UTF-8?B?TcOlbnMgUnVsbGfDpXJk?= <mans@mansr.com>,
        Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f196.google.com ([74.125.82.196]:34572 "EHLO
        mail-ot0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753328AbdASSAL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 13:00:11 -0500
Received: by mail-ot0-f196.google.com with SMTP id 73so5044748otj.1
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 09:59:23 -0800 (PST)
In-Reply-To: <yw1xbmv3j5ly.fsf@unicorn.mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/19/2017 09:56 AM, Måns Rullgård wrote:
> Mason <slash.tmp@free.fr> writes:
> 
>> One thing I find confusing... If the 8035 could work with the generic
>> PHY driver, what's the point of the at803x.ko driver?
> 
> Almost all Ethernet PHYs support the basic operation defined the by the
> standard.  Many have additional non-standardised features that require a
> specific driver.  Interrupts, for example.

Or special initial configuration wrt. (RG)MII modes, and runtime
configuration (EEE, link speeds, workarounds), obtaining useful counters
etc.

The generic PHY driver only deals with the standard MII registers (and
just a subset of it actually) while the PHY driver allows you to deal
with all the hardware specifics, the whole point behind having both
specialization and abstraction.
-- 
Florian
