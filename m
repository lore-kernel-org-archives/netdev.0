From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] netconsole: implement ipv4 tos support
Date: Thu, 1 Dec 2011 00:59:02 -0800
Message-ID: <CAHo-OoyQWk5xB7LcdCa+hLWvsiG-eY+Catdsa9zXG+01q3Y+3g@mail.gmail.com>
References: <1322702330-31325-1-git-send-email-zenczykowski@gmail.com>
	<20111130173435.5e63afda@nehalam.linuxnetplumber.net>
	<CANP3RGfwUr3ho3Tz_cfVz4CBJWMktOb7MDbUYYXz7XfjErw7Zg@mail.gmail.com>
	<20111130182753.02798425@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:44488 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752005Ab1LAI7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 03:59:03 -0500
Received: by yenl6 with SMTP id l6so1454543yen.19
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2011 00:59:02 -0800 (PST)
In-Reply-To: <20111130182753.02798425@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Although interpretation of TOS is per organization, in practice the

I think you meant 'in theory' :-)

> values are standardized in places like RFC4594. For example, routing protocols
> all use IPTOS_PREC_INTERNETCONTROL = 0xc0

Heh, ran into a bug based on this assumption just earlier today.
