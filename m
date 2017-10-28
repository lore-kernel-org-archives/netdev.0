From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: systemport: Correct IPG length settings
Date: Fri, 27 Oct 2017 17:52:44 -0700
Message-ID: <E25BBE5B-BF14-43B0-A0B8-1BA66FB11EDD@gmail.com>
References: <20171028003000.6114-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:45660 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750915AbdJ1Aw4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 20:52:56 -0400
Received: by mail-pf0-f179.google.com with SMTP id d28so6061198pfe.2
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 17:52:56 -0700 (PDT)
In-Reply-To: <20171028003000.6114-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On October 27, 2017 5:30:00 PM PDT, Florian Fainelli <f=2Efainelli@gmail=2E=
com> wrote:
>Due to a documentation mistake, the IPG length was set to 0x12 while it
>should have been 12 (decimal)=2E This would affect short packet (64B
>typically) performance since the IPG was bigger than necessary=2E
>

David, I will be sending a v2 which moves the IPG fix outside of the netde=
v_uses_dsa() clause since that is independent, unlike the GIB extension=2E =
Thanks!

--=20
Florian
