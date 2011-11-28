From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] netstamp_needed shouldn't be jump_label_key
Date: Mon, 28 Nov 2011 21:33:46 +0100
Message-ID: <1322512426.2970.15.camel@edumazet-laptop>
References: <igorm@etf.rs> <1322511796-6908-1-git-send-email-igorm@etf.rs>
	 <1322511796-6908-2-git-send-email-igorm@etf.rs>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:48365 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754458Ab1K1Udu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 15:33:50 -0500
Received: by lahl5 with SMTP id l5so680190lah.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 12:33:49 -0800 (PST)
In-Reply-To: <1322511796-6908-2-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 novembre 2011 =C3=A0 21:23 +0100, igorm@etf.rs a =C3=A9crit=
 :
> From: Igor Maravic <igorm@etf.rs>
>=20
> Problem with setting netstamp_needed as jump_label_key is that
> it inc/dec, functions net_enable_timestamp/net_disable_timestamp,
> are called from interrupts.
>=20
> That can cause DEADLOCK, because jump_label_{inc, dec} are using mute=
x locking,
> that may sleep.
>=20
> Signed-off-by: Igor Maravic <igorm@etf.rs>
>=20

Come on, we can find another way to handle this :)

Its net-next, we are allowed to try to find something better.
