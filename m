From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 5/5] 6lowpan: remove
	unecessary break
Date: Fri, 25 Oct 2013 17:11:48 +0400
Message-ID: <CAJmB2rCpX58gYMgdP1TRLem2Z3ex3ohRE+Sz-vt3odxCah2cEw@mail.gmail.com>
References: <1382647904-11311-1-git-send-email-alex.aring@gmail.com>
	<1382647904-11311-6-git-send-email-alex.aring@gmail.com>
	<EFDF4460-F8D0-4721-82F1-ABC3D5F75FDA@gmail.com>
	<526A6CB2.1040007@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5074427317188493906=="
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org"
	<linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <526A6CB2.1040007-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============5074427317188493906==
Content-Type: multipart/alternative; boundary=bcaec51a77822b2d6004e9907e8a

--bcaec51a77822b2d6004e9907e8a
Content-Type: text/plain; charset=ISO-8859-1

>
>
>  diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
>>> index e15b101..09350f1 100644
>>> --- a/net/ieee802154/6lowpan.c
>>> +++ b/net/ieee802154/6lowpan.c
>>> @@ -440,7 +440,6 @@ lowpan_uncompress_udp_header(**struct sk_buff *skb,
>>> struct udphdr *uh)
>>>         default:
>>>             pr_debug("ERROR: unknown UDP format\n");
>>>             goto err;
>>> -            break;
>>>         }
>>>
>>
>  It's not an unnecessary, it's let say a "good coding practice" to have a
>> break for every case including default.
>>
>
>    Even after *goto*? :-)
>
> WBR, Sergei
>

that's my fault, I missed goto here. I already declined my proposal, it's
silly.

--bcaec51a77822b2d6004e9907e8a
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote"><blo=
ckquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #c=
cc solid;padding-left:1ex"><div class=3D"im"><br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><blockquote class=3D"gmail_quote" style=3D"m=
argin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c<br>
index e15b101..09350f1 100644<br>
--- a/net/ieee802154/6lowpan.c<br>
+++ b/net/ieee802154/6lowpan.c<br>
@@ -440,7 +440,6 @@ lowpan_uncompress_udp_header(<u></u>struct sk_buff *skb=
, struct udphdr *uh)<br>
=A0 =A0 =A0 =A0 default:<br>
=A0 =A0 =A0 =A0 =A0 =A0 pr_debug(&quot;ERROR: unknown UDP format\n&quot;);<=
br>
=A0 =A0 =A0 =A0 =A0 =A0 goto err;<br>
- =A0 =A0 =A0 =A0 =A0 =A0break;<br>
=A0 =A0 =A0 =A0 }<br>
</blockquote></blockquote>
<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
It&#39;s not an unnecessary, it&#39;s let say a &quot;good coding practice&=
quot; to have a break for every case including default.<br>
</blockquote>
<br></div>
=A0 =A0Even after *goto*? :-)<br>
<br>
WBR, Sergei<br></blockquote><div><br></div><div>that&#39;s my fault, I miss=
ed goto here. I already declined my proposal, it&#39;s silly.</div></div></=
div></div>

--bcaec51a77822b2d6004e9907e8a--


--===============5074427317188493906==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
October Webinars: Code for Performance
Free Intel webinars can help you accelerate application performance.
Explore tips for MPI, OpenMP, advanced profiling, and more. Get the most from 
the latest Intel processors and coprocessors. See abstracts and register >
http://pubads.g.doubleclick.net/gampad/clk?id=60135991&iu=/4140/ostg.clktrk
--===============5074427317188493906==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linux-zigbee-devel mailing list
Linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel

--===============5074427317188493906==--
