From: "Andrew J. Bennieston" <a.j.bennieston@gmail.com>
Subject: Re: [PATCH net-next v10 7/7] xen-netfront: initialise
	queue name in xennet_init_queue
Date: Wed, 4 Jun 2014 10:35:41 +0100
Message-ID: <CAN48k6n1X5sk-f=F28Xo-OL1iKDXQprNj-x87xm2UPZm=sF4HQ@mail.gmail.com>
References: <1401874247-3202-1-git-send-email-wei.liu2@citrix.com>
	<1401874247-3202-8-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3679649638515838623=="
Cc: "ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"paul.durrant@citrix.com" <paul.durrant@citrix.com>,
	"david.vrabel@citrix.com" <david.vrabel@citrix.com>,
	"zoltan.kiss@citrix.com" <zoltan.kiss@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1401874247-3202-8-git-send-email-wei.liu2@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

--===============3679649638515838623==
Content-Type: multipart/alternative; boundary=001a11c2c9ca1919c304faff5a56

--001a11c2c9ca1919c304faff5a56
Content-Type: text/plain; charset=UTF-8

On Wednesday, 4 June 2014, Wei Liu <wei.liu2@citrix.com> wrote:

> Signed-off-by: Wei Liu <wei.liu2@citrix.com <javascript:;>>
> Reviewed-by: David Vrabel <david.vrabel@citrix.com <javascript:;>>
> ---
>  drivers/net/xen-netfront.c |    3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 55bf834..5a7872a 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -1665,6 +1665,9 @@ static int xennet_init_queue(struct netfront_queue
> *queue)
>         queue->rx_refill_timer.data = (unsigned long)queue;
>         queue->rx_refill_timer.function = rx_refill_timeout;
>
> +       snprintf(queue->name, sizeof(queue->name), "%s-q%u",
> +                queue->info->netdev->name, queue->id);
> +
>         /* Initialise tx_skbs as a free chain containing every entry. */
>         queue->tx_skb_freelist = 0;
>         for (i = 0; i < NET_TX_RING_SIZE; i++) {
> --
> 1.7.10.4
>
>
Reviewed-by: Andrew Bennieston <a.j.bennieston@gmail.com>


-- 
Andrew J. Bennieston

--001a11c2c9ca1919c304faff5a56
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Wednesday, 4 June 2014, Wei Liu &lt;<a href=3D"mailto:wei.liu2@citrix.co=
m">wei.liu2@citrix.com</a>&gt; wrote:<br><blockquote class=3D"gmail_quote" =
style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">Sig=
ned-off-by: Wei Liu &lt;<a href=3D"javascript:;" onclick=3D"_e(event, &#39;=
cvml&#39;, &#39;wei.liu2@citrix.com&#39;)">wei.liu2@citrix.com</a>&gt;<br>

Reviewed-by: David Vrabel &lt;<a href=3D"javascript:;" onclick=3D"_e(event,=
 &#39;cvml&#39;, &#39;david.vrabel@citrix.com&#39;)">david.vrabel@citrix.co=
m</a>&gt;<br>
---<br>
=C2=A0drivers/net/xen-netfront.c | =C2=A0 =C2=A03 +++<br>
=C2=A01 file changed, 3 insertions(+)<br>
<br>
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c<br>
index 55bf834..5a7872a 100644<br>
--- a/drivers/net/xen-netfront.c<br>
+++ b/drivers/net/xen-netfront.c<br>
@@ -1665,6 +1665,9 @@ static int xennet_init_queue(struct netfront_queue *q=
ueue)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 queue-&gt;rx_refill_timer.data =3D (unsigned lo=
ng)queue;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 queue-&gt;rx_refill_timer.function =3D rx_refil=
l_timeout;<br>
<br>
+ =C2=A0 =C2=A0 =C2=A0 snprintf(queue-&gt;name, sizeof(queue-&gt;name), &qu=
ot;%s-q%u&quot;,<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0queue-&gt;info-&gt=
;netdev-&gt;name, queue-&gt;id);<br>
+<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Initialise tx_skbs as a free chain containin=
g every entry. */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 queue-&gt;tx_skb_freelist =3D 0;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i &lt; NET_TX_RING_SIZE; i++) {<b=
r>
--<br>
1.7.10.4<br>
<br>
</blockquote><br><div>Reviewed-by: Andrew=C2=A0Bennieston &lt;<a href=3D"ma=
ilto:a.j.bennieston@gmail.com">a.j.bennieston@gmail.com</a>&gt;=C2=A0</div>=
<br><br>-- <br>Andrew J. Bennieston<br><br>

--001a11c2c9ca1919c304faff5a56--


--===============3679649638515838623==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Xen-devel mailing list
Xen-devel@lists.xen.org
http://lists.xen.org/xen-devel

--===============3679649638515838623==--
