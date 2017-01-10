From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net] net: socket: Make unnecessarily global
 sockfs_setattr() static
Date: Tue, 10 Jan 2017 17:32:11 +0900
Message-ID: <CAKD1Yr2NwsMBa93ALUWcsWqdOb2Qu=hz5hn3Urb2-x+OFLJMCQ@mail.gmail.com>
References: <20170110083051.753-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f175.google.com ([209.85.217.175]:33655 "EHLO
        mail-ua0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755374AbdAJIcc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 03:32:32 -0500
Received: by mail-ua0-f175.google.com with SMTP id i68so377718623uad.0
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 00:32:32 -0800 (PST)
In-Reply-To: <20170110083051.753-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 10, 2017 at 5:30 PM, Tobias Klauser <tklauser@distanz.ch> wrote:
> -int sockfs_setattr(struct dentry *dentry, struct iattr *iattr)
> +static int sockfs_setattr(struct dentry *dentry, struct iattr *iattr)

Acked-by: Lorenzo Colitti <lorenzo@google.com>
