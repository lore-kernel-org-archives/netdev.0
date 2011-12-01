From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] netconsole: implement ipv4 tos support
Date: Wed, 30 Nov 2011 18:11:32 -0800
Message-ID: <CANP3RGfwUr3ho3Tz_cfVz4CBJWMktOb7MDbUYYXz7XfjErw7Zg@mail.gmail.com>
References: <1322702330-31325-1-git-send-email-zenczykowski@gmail.com>
	<20111130173435.5e63afda@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:33725 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753289Ab1LACLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 21:11:33 -0500
Received: by yenl6 with SMTP id l6so1205664yen.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 18:11:33 -0800 (PST)
In-Reply-To: <20111130173435.5e63afda@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Why make it an option? TOS should always be set to interactive
> traffic (like telnet and slogin)

Because 'interactive' doesn't mean anything.  You don't know what
value of tos defines 'interactive' traffic on my network.
I may also consider network console/debug/dump/etc traffic less
important then say serving web traffic, and thus not even want it to
be considered 'interactive' in the first place.

TOS values are relevant within a LAN/WAN/Organization/AS, but are not
relevant internet-wide.
Almost all AS-boundary gateways/routers will do TOS remarking to their
own internal specifications.

- Maciej
