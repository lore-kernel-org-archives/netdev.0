From: Francois Saint-Jacques <fsaintjacques@gmail.com>
Subject: Re: [patch] socket.7: Document SO_INCOMING_CPU
Date: Mon, 20 Feb 2017 10:26:06 -0500
Message-ID: <CABNn7+o6Y0WLk-mo=__uA0UsdQAYp=oBTGBQsQHvWn23-cDJ3g@mail.gmail.com>
References: <CABNn7+rHfUTjMtm3Biqfx83G6Rr7pY-LuHXY=JqA6N3H_SstZg@mail.gmail.com>
 <63815aac-9c8f-c599-9422-5c312cefc9e8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-man@vger.kernel.org, netdev@vger.kernel.org,
        Eric Dumazet <edumazet@google.com>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f172.google.com ([209.85.216.172]:36621 "EHLO
        mail-qt0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753010AbdBTP0I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 10:26:08 -0500
Received: by mail-qt0-f172.google.com with SMTP id k15so89375986qtg.3
        for <netdev@vger.kernel.org>; Mon, 20 Feb 2017 07:26:07 -0800 (PST)
In-Reply-To: <63815aac-9c8f-c599-9422-5c312cefc9e8@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>               Because  all  of the packets for a single stream (i.e., all
>               packets for the same 4-tuple) arrive on the single RX queue

This is a configuration dependent behaviour and not always the
default. Maybe put a reference to `ethtool(8)` for more information
instead of possibly misleading the user?

Fran=C3=A7ois
