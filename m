From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: Re: [PATCH] sysctl: net: call unregister_net_sysctl_table where needed
Date: Sun, 1 May 2011 13:48:04 +0200
Message-ID: <BANLkTi=0-2aHDBtY2P794upF9brrW48aNA@mail.gmail.com>
References: <1304250241-26138-1-git-send-email-lucian.grijincu@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52375 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754015Ab1EALsZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2011 07:48:25 -0400
Received: by fxm17 with SMTP id 17so3255837fxm.19
        for <netdev@vger.kernel.org>; Sun, 01 May 2011 04:48:24 -0700 (PDT)
In-Reply-To: <1304250241-26138-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 1, 2011 at 1:44 PM, Lucian Adrian Grijincu
<lucian.grijincu@gmail.com> wrote:
> ctl_table_headers registered with register_net_sysctl_table should
> have been unregistered with the equivalent unregister_net_sysctl_tabl=
e
>
> Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>


David: I sent you this patch a while back but it was mixed with other
unrelated patches that were mostly ignored.

Again, to clarify: it does not matter at the moment if
register_net_sysctl_table or unregister_sysctl_table is called because
both to the same thing:


void unregister_net_sysctl_table(struct ctl_table_header *header)
{
        unregister_sysctl_table(header);
}
EXPORT_SYMBOL_GPL(unregister_net_sysctl_table);


We should either get rid of unregister_net_sysctl_table or use it consi=
stently.

--=20
=C2=A0.
=2E.: Lucian
