From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH] openvswitch: Add missing initialization in validate_and_copy_set_tun()
Date: Wed, 11 Feb 2015 13:31:20 -0800
Message-ID: <CALnjE+pwwqavXXkDC59rhBdWZihyxFZ+Hocj+HUQVYv_OSuRPQ@mail.gmail.com>
References: <1423650218-24666-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog111.obsmtp.com ([74.125.149.205]:34203 "HELO
	na3sys009aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753292AbbBKVbW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Feb 2015 16:31:22 -0500
Received: by mail-ie0-f179.google.com with SMTP id ar1so7394680iec.0
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2015 13:31:21 -0800 (PST)
In-Reply-To: <1423650218-24666-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 11, 2015 at 2:23 AM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> net/openvswitch/flow_netlink.c: In function =E2=80=98validate_and_cop=
y_set_tun=E2=80=99:
> net/openvswitch/flow_netlink.c:1749: warning: =E2=80=98err=E2=80=99 m=
ay be used uninitialized in this function
>
> If ipv4_tun_from_nlattr() returns a different positive value than
> OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS, err will be uninitialized, and
> validate_and_copy_set_tun() may return an undefined value instead of =
a
> zero success indicator. Initialize err to zero to fix this.
>
> Fixes: 1dd144cf5b4b47e1 ("openvswitch: Support VXLAN Group Policy ext=
ension")
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Acked-by: Pravin B Shelar <pshelar@nicira.com>
