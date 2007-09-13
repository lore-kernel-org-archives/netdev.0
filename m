From: Shirley Ma <xma@us.ibm.com>
Subject: [ofa-general] Re: InfiniBand/RDMA merge plans for 2.6.24
Date: Thu, 13 Sep 2007 15:16:40 -0700
Message-ID: <OFAE678C61.64C333F1-ON87257355.007A0B34-88257355.004E6EAD@us.ibm.com>
References: <aday7fal1qc.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0203691672=="
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org, netdev-owner@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <aday7fal1qc.fsf@cisco.com>
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

--===============0203691672==
Content-type: multipart/alternative;
	Boundary="0__=08BBF9C6DFE98DA48f9e8a93df938690918c08BBF9C6DFE98DA4"
Content-Disposition: inline

--0__=08BBF9C6DFE98DA48f9e8a93df938690918c08BBF9C6DFE98DA4
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: quoted-printable






netdev-owner@vger.kernel.org wrote on 09/13/2007 02:00:43 PM:

>  >         Since ehca can support 4K MTU, we would like to see a patc=
h in

>  > IPoIB to allow link MTU to be up to 4K instead of current 2K for
2.6.24
>  > kernel. The idea is IPoIB link MTU will pick up a return value fro=
m
SM's
>  > default broadcast MTU. This patch should be a small patch, I hope =
you
are
>  > OK with this.
>
> It's actually not small, since it turns the skb allocation into a
> 4100-byte buffer, which ends up being more than 1 page usually, which=

> means it fails if memory is fragmented.
>
> Anyway given the backlog anything substantial that hasn't been posted=

> already is almost surely going to have to wait until 2.6.25.

The patch is just needed to pick up broadcast MTU size instead of hard
coding 2K right now. SKB allocation shouldn't be different with Etherne=
t
Jambo Frame and IPoIB-CM which 64K MTU. I don't understand why it's
different. Could you please explain this?

Thanks
Shirley=

--0__=08BBF9C6DFE98DA48f9e8a93df938690918c08BBF9C6DFE98DA4
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline
Content-transfer-encoding: quoted-printable

<html><body>
<p><tt>netdev-owner@vger.kernel.org wrote on 09/13/2007 02:00:43 PM:<br=
>
<br>
&gt; &nbsp;&gt; &nbsp; &nbsp; &nbsp; &nbsp; Since ehca can support 4K M=
TU, we would like to see a patch in <br>
&gt; &nbsp;&gt; IPoIB to allow link MTU to be up to 4K instead of curre=
nt 2K for 2.6.24 <br>
&gt; &nbsp;&gt; kernel. The idea is IPoIB link MTU will pick up a retur=
n value from SM's <br>
&gt; &nbsp;&gt; default broadcast MTU. This patch should be a small pat=
ch, I hope you are <br>
&gt; &nbsp;&gt; OK with this.<br>
&gt; <br>
&gt; It's actually not small, since it turns the skb allocation into a<=
br>
&gt; 4100-byte buffer, which ends up being more than 1 page usually, wh=
ich<br>
&gt; means it fails if memory is fragmented.<br>
&gt; <br>
&gt; Anyway given the backlog anything substantial that hasn't been pos=
ted<br>
&gt; already is almost surely going to have to wait until 2.6.25.<br>
</tt><br>
<tt>The patch is just needed to pick up broadcast MTU size instead of h=
ard coding 2K right now. SKB allocation shouldn't be different with Eth=
ernet Jambo Frame and IPoIB-CM which 64K MTU. I don't understand why it=
's different. Could you please explain this?</tt><br>
<br>
<tt>Thanks</tt><br>
<tt>Shirley</tt></body></html>=

--0__=08BBF9C6DFE98DA48f9e8a93df938690918c08BBF9C6DFE98DA4--


--===============0203691672==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============0203691672==--
