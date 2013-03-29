From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 1/6] net-next: replace obsolete NLMSG_* with type safe
 nlmsg_*
Date: Thu, 28 Mar 2013 22:57:41 -0400
Message-ID: <51550325.6040000@hp.com>
References: <1364402824-32680-1-git-send-email-honkiko@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, stephen@networkplumber.org, tgraf@suug.ch
To: Hong Zhiguo <honkiko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364402824-32680-1-git-send-email-honkiko@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/27/2013 12:47 PM, Hong Zhiguo wrote:
> Signed-off-by: Hong Zhiguo <honkiko@gmail.com>

> diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
> index 97351e1..9247252 100644
> --- a/net/ieee802154/netlink.c
> +++ b/net/ieee802154/netlink.c
> @@ -65,7 +65,7 @@ struct sk_buff *ieee802154_nl_create(int flags, u8 =
req)
>  int ieee802154_nl_mcast(struct sk_buff *msg, unsigned int group)
>  {
>  	/* XXX: nlh is right at the start of msg */
> -	void *hdr =3D genlmsg_data(NLMSG_DATA(msg->data));
> +	void *hdr =3D genlmsg_data(nlmsg_data(msg->data));
> =20
>  	if (genlmsg_end(msg, hdr) < 0)
>  		goto out;
> @@ -98,7 +98,7 @@ struct sk_buff *ieee802154_nl_new_reply(struct genl=
_info *info,
>  int ieee802154_nl_reply(struct sk_buff *msg, struct genl_info *info)
>  {
>  	/* XXX: nlh is right at the start of msg */
> -	void *hdr =3D genlmsg_data(NLMSG_DATA(msg->data));
> +	void *hdr =3D genlmsg_data(nlmsg_data(msg->data));
> =20
>  	if (genlmsg_end(msg, hdr) < 0)
>  		goto out;

  CC [M]  net/ieee802154/netlink.o
net/ieee802154/netlink.c: In function =91ieee802154_nl_mcast=92:
net/ieee802154/netlink.c:68: warning: passing argument 1 of =91nlmsg_da=
ta=92 from
incompatible pointer type
include/net/netlink.h:302: note: expected =91const struct nlmsghdr *=92=
 but argument
is of type =91unsigned char *=92
net/ieee802154/netlink.c: In function =91ieee802154_nl_reply=92:
net/ieee802154/netlink.c:101: warning: passing argument 1 of =91nlmsg_d=
ata=92 from
incompatible pointer type
include/net/netlink.h:302: note: expected =91const struct nlmsghdr *=92=
 but argument
is of type =91unsigned char *=92

-Brian
