From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2] regression in ss output
Date: Mon, 16 Oct 2017 14:28:07 -0700
Message-ID: <20171016142807.47825131@xeon-e3>
References: <AM4PR0901MB125261BF480B49D2BA2DF46BCC480@AM4PR0901MB1252.eurprd09.prod.outlook.com>
        <20171016103320.GP11332@orbyte.nwl.cc>
        <AM4PR0901MB12527C55F04814777A0E6849CC4F0@AM4PR0901MB1252.eurprd09.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Humberto Alves <hjalves@live.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:55449 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752476AbdJPV2K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 17:28:10 -0400
Received: by mail-pf0-f176.google.com with SMTP id 17so16724311pfn.12
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 14:28:10 -0700 (PDT)
In-Reply-To: <AM4PR0901MB12527C55F04814777A0E6849CC4F0@AM4PR0901MB1252.eurprd09.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Oct 2017 20:44:07 +0000
Humberto Alves <hjalves@live.com> wrote:

> Yes, just get rid of this 'if statement'.
> in6addr_any should be represented as '::', not '*'. Otherwise it's 
> impossible to distinguish IPv4 listening addresses from IPv6. Thank you :)

But IPv6 accepts IPv4 as well.
