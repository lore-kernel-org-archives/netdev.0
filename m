From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2] af-packet: fix oops when socket is not present
Date: Tue, 6 Nov 2012 13:28:48 +0100
Message-ID: <20121106122848.GB20904@kroah.com>
References: <1352201642.3140.880.camel@edumazet-glaptop>
 <1352203810-957-1-git-send-email-eric@regit.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, stable@vger.kernel.org
To: Eric Leblond <eric@regit.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:65509 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846Ab2KFM2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 07:28:40 -0500
Received: by mail-wi0-f178.google.com with SMTP id hr7so390977wib.1
        for <netdev@vger.kernel.org>; Tue, 06 Nov 2012 04:28:39 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1352203810-957-1-git-send-email-eric@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 06, 2012 at 01:10:10PM +0100, Eric Leblond wrote:
> Due to a NULL dereference, the following patch is causing oops
> in normal trafic condition:
>=20
> commit c0de08d04215031d68fa13af36f347a6cfa252ca
> Author: Eric Leblond <eric@regit.org>
> Date:=A0=A0 Thu Aug 16 22:02:58 2012 +0000
>=20
> =A0=A0=A0 af_packet: don't emit packet on orig fanout group
>=20
> This buggy patch was a feature fix and has reached most stable
> branches.
>=20
> When skb->sk is NULL and when packet fanout is used, there is a
> crash in match_fanout_group where skb->sk is accessed.
> This patch fixes the issue by returning false as soon as the
> socket is NULL: this correspond to the wanted behavior because
> the kernel as to resend the skb to all the listening socket in
> this case.
>=20
> Signed-off-by: Eric Leblond <eric@regit.org>
> ---
>  net/core/dev.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>
