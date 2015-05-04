From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 5/7] ip-route: don't hide routes with RTM_F_CLONED by
 default
Date: Mon, 4 May 2015 08:37:51 -0700
Message-ID: <20150504083751.7c38626b@urahara>
References: <1428933661-8193-2-git-send-email-pavlix@pavlix.net>
	<1428933661-8193-5-git-send-email-pavlix@pavlix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, psimerda@redhat.com
To: Pavel =?UTF-8?B?xaBpbWVyZGE=?= <pavlix@pavlix.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:34961 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750943AbbEDPh4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 11:37:56 -0400
Received: by pdbqd1 with SMTP id qd1so166226590pdb.2
        for <netdev@vger.kernel.org>; Mon, 04 May 2015 08:37:55 -0700 (PDT)
In-Reply-To: <1428933661-8193-5-git-send-email-pavlix@pavlix.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Apr 2015 16:00:59 +0200
Pavel =C5=A0imerda <pavlix@pavlix.net> wrote:

> From: Pavel =C5=A0imerda <psimerda@redhat.com>
>=20
> Signed-off-by: Pavel =C5=A0imerda <psimerda@redhat.com>
> ---
>  ip/iproute.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

I understand your concern, and it probably was a poor design choice ini=
tially.

Since this will change the output for the default case, it will upset s=
ome
peoples expectations and potentially break scripts that screen scrape t=
he output
of ip commands. Therefore I can't accept it at this time.

Sorry for the delay, but I thought someone else would add more comments=
=2E
Perhaps if you explained in more detail the motivation of why this is a=
n
important problem I would reconsider change the behavior.
