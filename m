From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 6/6] 6lowpan: return the
 dev_queue_xmit() return value from lowpan_xmit()
Date: Tue, 2 Apr 2013 23:27:00 +0400
Message-ID: <CAJmB2rAqc=YVF5t2rxRso7jPYWr7zSSd7oRXvuf6Sq=yEiMGPg@mail.gmail.com>
References: <1364928481-1813-1-git-send-email-alan@signal11.us>
	<1364928481-1813-7-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3350555458125182694=="
Cc: "open list:NETWORKING \[GENERAL\]" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-zigbee-devel <linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1364928481-1813-7-git-send-email-alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============3350555458125182694==
Content-Type: multipart/alternative; boundary=f46d041c463cb0fa0204d965b84e

--f46d041c463cb0fa0204d965b84e
Content-Type: text/plain; charset=ISO-8859-1

2013/4/2 Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>

> dev_queue_xmit() will return a positive value if the packet could not be
> queued, often because the real network device (in our case the mac802154
> wpan device) has its queue stopped.  lowpan_xmit() should return that value
> to the higher layer so the higher layer will retry sending the packet.
>
> Signed-off-by: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
> ---
>  net/ieee802154/6lowpan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> index a68c792..55e1fd5 100644
> --- a/net/ieee802154/6lowpan.c
> +++ b/net/ieee802154/6lowpan.c
> @@ -1142,7 +1142,7 @@ out:
>         if (err)
>                 pr_debug("ERROR: xmit failed\n");
>
> -       return (err < 0 ? NETDEV_TX_BUSY : NETDEV_TX_OK);
> +       return (err < 0) ? NET_XMIT_DROP : err;
>  }
>
>  static struct wpan_phy *lowpan_get_phy(const struct net_device *dev)
> --
> 1.7.11.2
>
> this patch should be a part of previous one.

--f46d041c463cb0fa0204d965b84e
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">2013=
/4/2 Alan Ott <span dir=3D"ltr">&lt;<a href=3D"mailto:alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org" tar=
get=3D"_blank">alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org</a>&gt;</span><br><blockquote class=3D"gmai=
l_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left=
:1ex">
dev_queue_xmit() will return a positive value if the packet could not be<br=
>
queued, often because the real network device (in our case the mac802154<br=
>
wpan device) has its queue stopped. =A0lowpan_xmit() should return that val=
ue<br>
to the higher layer so the higher layer will retry sending the packet.<br>
<br>
Signed-off-by: Alan Ott &lt;<a href=3D"mailto:alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org">alan@signal=
11.us</a>&gt;<br>
---<br>
=A0net/ieee802154/6lowpan.c | 2 +-<br>
=A01 file changed, 1 insertion(+), 1 deletion(-)<br>
<br>
diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c<br>
index a68c792..55e1fd5 100644<br>
--- a/net/ieee802154/6lowpan.c<br>
+++ b/net/ieee802154/6lowpan.c<br>
@@ -1142,7 +1142,7 @@ out:<br>
=A0 =A0 =A0 =A0 if (err)<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug(&quot;ERROR: xmit failed\n&quot;);=
<br>
<br>
- =A0 =A0 =A0 return (err &lt; 0 ? NETDEV_TX_BUSY : NETDEV_TX_OK);<br>
+ =A0 =A0 =A0 return (err &lt; 0) ? NET_XMIT_DROP : err;<br>
=A0}<br>
<br>
=A0static struct wpan_phy *lowpan_get_phy(const struct net_device *dev)<br>
<span class=3D"HOEnZb"><font color=3D"#888888">--<br>
1.7.11.2<br>
<br></font></span></blockquote><div>this patch should be a part of previous=
 one. <br></div></div><br></div></div>

--f46d041c463cb0fa0204d965b84e--


--===============3350555458125182694==
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
--===============3350555458125182694==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linux-zigbee-devel mailing list
Linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel

--===============3350555458125182694==--
