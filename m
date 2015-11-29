From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: Increasing skb->mark size
Date: Sun, 29 Nov 2015 17:37:11 +0900
Message-ID: <CAKD1Yr3URKzAooiNH7i4kHVR0-TQjEAkQEdqjarAm6uxH7u-Mw@mail.gmail.com>
References: <1448397144.14854.27.camel@mattb-dl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Luuk Paulussen <Luuk.Paulussen@alliedtelesis.co.nz>
To: Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f173.google.com ([209.85.160.173]:34938 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193AbbK2Ihb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 03:37:31 -0500
Received: by ykba77 with SMTP id a77so154283096ykb.2
        for <netdev@vger.kernel.org>; Sun, 29 Nov 2015 00:37:30 -0800 (PST)
In-Reply-To: <1448397144.14854.27.camel@mattb-dl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 25, 2015 at 5:32 AM, Matt Bennett
<Matt.Bennett@alliedtelesis.co.nz> wrote:
> I'm emailing this list for feedback on the feasibility of increasing
> skb->mark or adding a new field for marking. Perhaps this extension
> could be done under a new CONFIG option.

64-bit marks (both skb->mark and sk->sk_mark) would be useful for
hosts doing complex policy routing as well. Current Android releases
use 20 of the 32 bits. If the mark were 64 bits, we could put the UID
in it, and stop using ip rules to implement per-UID routing.
