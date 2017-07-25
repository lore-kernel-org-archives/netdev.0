From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip route: replace exits with returns
Date: Tue, 25 Jul 2017 11:42:16 -0700
Message-ID: <20170725114216.5640961f@xeon-e3>
References: <20170722224202.5602-1-elie@bouttier.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org
To: elie@bouttier.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35432 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750973AbdGYSmX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 14:42:23 -0400
Received: by mail-pf0-f169.google.com with SMTP id h29so26511031pfd.2
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 11:42:23 -0700 (PDT)
In-Reply-To: <20170722224202.5602-1-elie@bouttier.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 23 Jul 2017 00:42:02 +0200
elie@bouttier.eu wrote:

> From: =C3=89lie Bouttier <elie@bouttier.eu>
>=20
> This patch replaces exits with returns in ip route
> commands.
>=20
> Allows to continue when invoked with ip -batch.
>=20
> Signed-off-by: =C3=89lie Bouttier <elie@bouttier.eu>

Sure applied, but any attempt to continue after some of these kernel
communication errors is unlikely to work.
