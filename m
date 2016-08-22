From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v05 38/72] include/uapi/linux/openvswitch.h: use __u32
 from linux/types.h
Date: Mon, 22 Aug 2016 12:39:38 -0700
Message-ID: <20160822123938.02e885c4@xeon-e3>
References: <1471890809-4383-1-git-send-email-mikko.rapeli@iki.fi>
        <1471890809-4383-39-git-send-email-mikko.rapeli@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, Pravin Shelar <pshelar@nicira.com>,
        netdev@vger.kernel.org, dev@openvswitch.org
To: Mikko Rapeli <mikko.rapeli@iki.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471890809-4383-39-git-send-email-mikko.rapeli@iki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 22 Aug 2016 20:32:55 +0200
Mikko Rapeli <mikko.rapeli@iki.fi> wrote:

> Fixes userspace compiler error:
>=20
> error: unknown type name =E2=80=98uint32_t=E2=80=99
>=20
> Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
> ---
>  include/uapi/linux/openvswitch.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvs=
witch.h
> index d95a301..645499a 100644
> --- a/include/uapi/linux/openvswitch.h
> +++ b/include/uapi/linux/openvswitch.h
> @@ -632,8 +632,8 @@ enum ovs_hash_alg {
>   * @hash_basis: basis used for computing hash.
>   */
>  struct ovs_action_hash {
> -	uint32_t  hash_alg;     /* One of ovs_hash_alg. */
> -	uint32_t  hash_basis;
> +	__u32  hash_alg;     /* One of ovs_hash_alg. */
> +	__u32  hash_basis;
>  };
> =20
>  /**

This is a a real issue, but being buried in a huge patch series of include
file stuff I don't think anyone would see it.
