From: Venkatesh Srinivas via Virtualization
	<virtualization@lists.linux-foundation.org>
Subject: Re: [PATCH net-next] virtio_net: replace netdev_alloc_skb_ip_align()
	with napi_alloc_skb()
Date: Thu, 17 Mar 2016 18:00:12 -0700
Message-ID: <CAHdzE-90TvqCqWc-8kPDQW76qVUV-LYOfPOqjjh7=anxS1SV_A@mail.gmail.com>
References: <b436c3eb5d4c19e92184c27d89ec8118d6fd3f81.1458224603.git.pabeni@redhat.com>
Reply-To: Venkatesh Srinivas <venkateshs@google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6853299436111274481=="
Cc: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	virtualization@lists.linux-foundation.org
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <b436c3eb5d4c19e92184c27d89ec8118d6fd3f81.1458224603.git.pabeni@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

--===============6853299436111274481==
Content-Type: multipart/alternative; boundary=001a113e6600f42e2d052e4844a3

--001a113e6600f42e2d052e4844a3
Content-Type: text/plain; charset=UTF-8

On Thu, Mar 17, 2016 at 7:44 AM, Paolo Abeni <pabeni@redhat.com> wrote:

> This gives small but noticeable rx performance improvement (2-3%)
> and will allow exploiting future napi improvement.
>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
>

Worked in my tests, though the performance win was in the noise (+0.6% -
+1% bandwidth).
What tests did you see a 2-3% win on?

Do you think its worth modifying add_recvbuf_small() to use
napi_alloc_skb() when called from
Rx NAPI (virtnet_receive)?

Tested-by: Venkatesh Srinivas <venkateshs@google.com>

Thanks,
-- vs;

--001a113e6600f42e2d052e4844a3
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">On T=
hu, Mar 17, 2016 at 7:44 AM, Paolo Abeni <span dir=3D"ltr">&lt;<a href=3D"m=
ailto:pabeni@redhat.com" target=3D"_blank">pabeni@redhat.com</a>&gt;</span>=
 wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;bor=
der-left:1px #ccc solid;padding-left:1ex">This gives small but noticeable r=
x performance improvement (2-3%)<br>
and will allow exploiting future napi improvement.<br>
<br>
Signed-off-by: Paolo Abeni &lt;<a href=3D"mailto:pabeni@redhat.com">pabeni@=
redhat.com</a>&gt;<br></blockquote><div>=C2=A0</div><div>Worked in my tests=
, though the performance win was in the noise (+0.6% - +1% bandwidth).</div=
><div>What tests did you see a 2-3% win on?</div><div><br></div><div>Do you=
 think its worth modifying add_recvbuf_small() to use napi_alloc_skb() when=
 called from</div><div>Rx NAPI (virtnet_receive)?</div><div><br></div><div>=
Tested-by: Venkatesh Srinivas &lt;<a href=3D"mailto:venkateshs@google.com">=
venkateshs@google.com</a>&gt;</div><div><br></div><div>Thanks,</div><div>--=
 vs;</div></div>
</div></div>

--001a113e6600f42e2d052e4844a3--

--===============6853299436111274481==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============6853299436111274481==--
