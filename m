From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] man ip-link: Add missing lowpan link type
Date: Mon, 11 May 2015 09:21:46 -0700
Message-ID: <20150511092146.148846e5@urahara>
References: <20150511071714.GP11014@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:34427 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753814AbbEKQVp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 12:21:45 -0400
Received: by pdbqa5 with SMTP id qa5so147888131pdb.1
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 09:21:45 -0700 (PDT)
In-Reply-To: <20150511071714.GP11014@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 May 2015 10:17:14 +0300
Lennert Buytenhek <buytenh@wantstofly.org> wrote:

> Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>
> ---
> These man pages don't use .nh when describing command invocation synt=
ax,
> so we end up with things like this (on 80 character terminals):
>=20
>               ip link add DEVICE type vxlan id ID [ dev PHYS_DEV  ] [=
 { group
>               | remote } IPADDR ] [ local IPADDR ] [ ttl TTL ] [ tos =
TOS ] [
>               port MIN MAX ] [ [no]learning ] [ [no]proxy ] [ [no]rsc=
 ] [
>               [no]l2miss ] [ [no]l3miss ] [ ageing SECONDS ] [ maxadd=
ress NUM=E2=80=90
>               BER ] [ gbp ]
>=20
> and:
>=20
>               ip link add DEVICE type { gre | ipip | sit }  remote AD=
DR local
>               ADDR [ encap { fou | gue | none } ] [ encap-sport { POR=
T | auto
>               } ] [ encap-dport PORT ] [  [no]encap-csum ] [  [no]enc=
ap-remc=E2=80=90
>               sum ]
>=20
> and this affects this addition as well:
>=20
>        TYPE :=3D [ bridge | bond | can | dummy | hsr | ifb | ipoib | =
macvlan |
>                macvtap | vcan | veth | vlan | vxlan | ip6tnl | ipip |=
 sit |
>                gre | gretap | ip6gre | ip6gretap | vti | nlmon | ipvl=
an | low=E2=80=90
>                pan ]
>=20
> A possible fix for this would be to put these descriptions in an
> environment with hyphenation mode zero.
>=20

Applied.
Not sure what the best silly nroff fix for the hyphenation nonsense is.
