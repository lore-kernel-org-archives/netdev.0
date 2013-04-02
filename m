From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 5/6] 6lowpan: handle dev_queue_xmit
	error code properly
Date: Tue, 2 Apr 2013 23:21:41 +0400
Message-ID: <CAJmB2rB+9-gLV=SVvr4JUc2swjmTaWxD0gYM5VLw8PL1d455JA@mail.gmail.com>
References: <1364928481-1813-1-git-send-email-alan@signal11.us>
	<1364928481-1813-6-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4326961634076231819=="
Cc: "open list:NETWORKING \[GENERAL\]" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-zigbee-devel <linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1364928481-1813-6-git-send-email-alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============4326961634076231819==
Content-Type: multipart/alternative; boundary=485b3979db48aaab6604d965a5db

--485b3979db48aaab6604d965a5db
Content-Type: text/plain; charset=ISO-8859-1

2013/4/2 Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>

> dev_queue_xmit() can return positive error codes, so check for nonzero.
>
> Signed-off-by: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
> ---
>  net/ieee802154/6lowpan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> index e1b4580..a68c792 100644
> --- a/net/ieee802154/6lowpan.c
> +++ b/net/ieee802154/6lowpan.c
> @@ -1139,7 +1139,7 @@ static netdev_tx_t lowpan_xmit(struct sk_buff *skb,
> struct net_device *dev)
>  error:
>         dev_kfree_skb(skb);
>  out:
> -       if (err < 0)
> +       if (err)
>
lets say ok....

>                 pr_debug("ERROR: xmit failed\n");
>
>         return (err < 0 ? NETDEV_TX_BUSY : NETDEV_TX_OK);
>
but here you still checks for negative error only, why?

> --
> 1.7.11.2
>
>

--485b3979db48aaab6604d965a5db
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><br><div class=3D"gmail=
_quote">2013/4/2 Alan Ott <span dir=3D"ltr">&lt;<a href=3D"mailto:alan@sign=
al11.us" target=3D"_blank">alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org</a>&gt;</span><br><blockquote c=
lass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;=
padding-left:1ex">
dev_queue_xmit() can return positive error codes, so check for nonzero.<br>
<br>
Signed-off-by: Alan Ott &lt;<a href=3D"mailto:alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org">alan@signal=
11.us</a>&gt;<br>
---<br>
=A0net/ieee802154/6lowpan.c | 2 +-<br>
=A01 file changed, 1 insertion(+), 1 deletion(-)<br>
<br>
diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c<br>
index e1b4580..a68c792 100644<br>
--- a/net/ieee802154/6lowpan.c<br>
+++ b/net/ieee802154/6lowpan.c<br>
@@ -1139,7 +1139,7 @@ static netdev_tx_t lowpan_xmit(struct sk_buff *skb, s=
truct net_device *dev)<br>
=A0error:<br>
=A0 =A0 =A0 =A0 dev_kfree_skb(skb);<br>
=A0out:<br>
- =A0 =A0 =A0 if (err &lt; 0)<br>
+ =A0 =A0 =A0 if (err)<br></blockquote><div>lets say ok.... <br></div><bloc=
kquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #cc=
c solid;padding-left:1ex">
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug(&quot;ERROR: xmit failed\n&quot;);=
<br>
<br>
=A0 =A0 =A0 =A0 return (err &lt; 0 ? NETDEV_TX_BUSY : NETDEV_TX_OK);<br></b=
lockquote><div>but here you still checks for negative error only, why?<br><=
/div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-le=
ft:1px #ccc solid;padding-left:1ex">

<span class=3D"HOEnZb"><font color=3D"#888888">--<br>
1.7.11.2<br>
<br>
</font></span></blockquote></div><br></div></div>

--485b3979db48aaab6604d965a5db--


--===============4326961634076231819==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Minimize network downtime and maximize team effectiveness.
Reduce network management and security costs.Learn how to hire 
the most talented Cisco Certified professionals. Visit the 
Employer Resources Portal
http://www.cisco.com/web/learning/employer_resources/index.html
--===============4326961634076231819==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linux-zigbee-devel mailing list
Linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel

--===============4326961634076231819==--
