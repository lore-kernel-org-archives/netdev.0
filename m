From: Lawrence Brakmo <brakmo@fb.com>
Subject: Re: [PATCH net-next 5/7] tcp_nv: make tcpnv_get_info static
Date: Tue, 10 Jan 2017 19:50:35 +0000
Message-ID: <D49A76C3.24037%brakmo@fb.com>
References: <20170110181816.18991-1-sthemmin@microsoft.com>
 <20170110181816.18991-6-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Stephen Hemminger <sthemmin@microsoft.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:39119 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1032585AbdAJTuo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 14:50:44 -0500
In-Reply-To: <20170110181816.18991-6-sthemmin@microsoft.com>
Content-Language: en-US
Content-ID: <342028F2B05B1444A6DAC6200AF12EFD@namprd15.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/10/17, 10:18 AM, "netdev-owner@vger.kernel.org on behalf of Stephen
Hemminger" <netdev-owner@vger.kernel.org on behalf of
stephen@networkplumber.org> wrote:

>Function only used in this file.
>
>Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
>---
> net/ipv4/tcp_nv.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
>
>diff --git a/net/ipv4/tcp_nv.c b/net/ipv4/tcp_nv.c
>index 5de82a8d4d87..0065f44c40c1 100644
>--- a/net/ipv4/tcp_nv.c
>+++ b/net/ipv4/tcp_nv.c
>@@ -424,8 +424,8 @@ static void tcpnv_acked(struct sock *sk, const struct
>ack_sample *sample)
> }
>=20
> /* Extract info for Tcp socket info provided via netlink */
>-size_t tcpnv_get_info(struct sock *sk, u32 ext, int *attr,
>-		      union tcp_cc_info *info)
>+static size_t tcpnv_get_info(struct sock *sk, u32 ext, int *attr,
>+			     union tcp_cc_info *info)
> {
> 	const struct tcpnv *ca =3D inet_csk_ca(sk);
>=20
>--=20
>2.11.0
>

You should also remove the line:
EXPORT_SYMBOL_GPL(tcpnv_get_info);
