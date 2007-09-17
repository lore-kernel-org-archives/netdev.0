From: Shirley Ma <xma@us.ibm.com>
Subject: [ofa-general] Re: InfiniBand/RDMA merge plans for 2.6.24
Date: Mon, 17 Sep 2007 15:24:12 -0700
Message-ID: <OF78D6A855.4B576934-ON87257359.007A1F1F-88257359.004F1EB6@us.ibm.com>
References: <ada1wcxnev5.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2026346412=="
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org, netdev-owner@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <ada1wcxnev5.fsf@cisco.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Mime-version: 1.0
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

--===============2026346412==
Content-type: multipart/alternative;
	Boundary="0__=08BBF9CADFE9998F8f9e8a93df938690918c08BBF9CADFE9998F"
Content-Disposition: inline

--0__=08BBF9CADFE9998F8f9e8a93df938690918c08BBF9CADFE9998F
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: quoted-printable






netdev-owner@vger.kernel.org wrote on 09/17/2007 02:47:42 PM:

>  > > IPoIB CM handles this properly by gathering together single page=
s in
>  > > skbs' fragment lists.
>
>  > Then can we reuse IPoIB CM code here?
>
> Yes, if possible, refactoring things so that the rx skb allocation
> code becomes common between CM and non-CM would definitely make sense=
.

This is also applied to MTU=3D2K size as well since ppage size is great=
er
than 2K on different platforms is not guaranteed. This skb issue is an
independent effort with supporting MTU=3D4K. We need to address non-CM =
skb
issue in general. Let's have a simple patch to enable MTU=3D4K support =
first
in 2.6.24, then address non-CM skb issue in a different patch next, Do =
you
agree?

Thanks
Shirley



=

--0__=08BBF9CADFE9998F8f9e8a93df938690918c08BBF9CADFE9998F
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline
Content-transfer-encoding: quoted-printable

<html><body>
<p><tt>netdev-owner@vger.kernel.org wrote on 09/17/2007 02:47:42 PM:<br=
>
<br>
&gt; &nbsp;&gt; &gt; IPoIB CM handles this properly by gathering togeth=
er single pages in<br>
&gt; &nbsp;&gt; &gt; skbs' fragment lists.<br>
&gt; <br>
&gt; &nbsp;&gt; Then can we reuse IPoIB CM code here?<br>
&gt; <br>
&gt; Yes, if possible, refactoring things so that the rx skb allocation=
<br>
&gt; code becomes common between CM and non-CM would definitely make se=
nse.<br>
</tt><br>
This is also applied to MTU=3D2K size as well since ppage size is great=
er than 2K on different platforms is not guaranteed. This skb issue is =
an independent effort with supporting MTU=3D4K. We need to address non-=
CM skb issue in general. Let's have a simple patch to enable MTU=3D4K s=
upport first in 2.6.24, then address non-CM skb issue in a different pa=
tch next, Do you agree?<br>
<br>
Thanks<br>
Shirley <br>
<br>
<br>
<br>
<tt><br>
</tt></body></html>=

--0__=08BBF9CADFE9998F8f9e8a93df938690918c08BBF9CADFE9998F--


--===============2026346412==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============2026346412==--
