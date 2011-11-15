From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] vlan:return error when real dev is enslaved
Date: Tue, 15 Nov 2011 16:46:48 +0800
Message-ID: <CAM_iQpXCtH1cSJFsWVGrdreyhBgAjujLygktQGrK7iP-zyhN5g@mail.gmail.com>
References: <c897fa89d5ea94c6624e8cdab9787aa83526f994.1321343212.git.wpan@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	"open list:VLAN (802.1Q)" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Weiping Pan <wpan@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:65185 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753857Ab1KOIqt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 03:46:49 -0500
In-Reply-To: <c897fa89d5ea94c6624e8cdab9787aa83526f994.1321343212.git.wpan@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 15, 2011 at 4:36 PM, Weiping Pan <wpan@redhat.com> wrote:
> + =C2=A0 =C2=A0 =C2=A0 if (real_dev->flags & IFF_SLAVE) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pr_info("Error, %s=
 was already enslaved\n", name);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EOPNOTSUPP=
;
> + =C2=A0 =C2=A0 =C2=A0 }

Use pr_err() then.
