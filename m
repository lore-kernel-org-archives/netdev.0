From: Shirley Ma <xma@us.ibm.com>
Subject: Re: [PATCH] IPv6 MIB:ipv6RouterAdvert netlink notification
Date: Fri, 16 Jan 2004 10:38:49 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFDFE3736C.20FD7F98-ON87256E1D.00662F80@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=08BBE48EDFF5A9108f9e8a93df938690918c08BBE48EDFF5A910"
Cc: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>,
        mashirle@us.ibm.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=08BBE48EDFF5A9108f9e8a93df938690918c08BBE48EDFF5A910
Content-type: text/plain; charset=US-ASCII





Thank Yoshfuji to point out.

But the patch is still needed for the Router, so it should be put in
ndisc_router_discovery() when it's determined as a router. Are you OK with
that?

Thanks
Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone: (503) 578-7638
FAX:      (503) 578-3228



"David S. Miller" <davem@redhat.com> on 01/16/2004 02:01:34 AM

To:    "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
cc:    Shirley Ma/Beaverton/IBM@IBMUS, mashirle@us.ltcfwd.linux.ibm.com,
       kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Subject:    Re: [PATCH] IPv6 MIB:ipv6RouterAdvert netlink notification


On Fri, 16 Jan 2004 10:37:10 +0900 (JST)
YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:

> In article <OFB4F51C5A.FC479F2C-ON87256E1C.007B64B8@us.ibm.com> (at Thu,
15 Jan 2004 14:31:47 -0800), Shirley Ma <xma@us.ibm.com> says:
>
> > This patch is going to be used by SNMP for ipv6RouterAdvert Table. I
will
> > remove this Micro, and resubmit the patch.
>
> This patch is conceptually wrong.

Ok, since this is controversial I'll back it out of my tree.


--0__=08BBE48EDFF5A9108f9e8a93df938690918c08BBE48EDFF5A910
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Thank Yoshfuji to point out. <br>
<br>
But the patch is still needed for the Router, so it should be put in ndisc_router_discovery() when it's determined as a router. Are you OK with that?<br>
<br>
Thanks<br>
Shirley Ma<br>
IBM Linux Technology Center<br>
15300 SW Koll Parkway<br>
Beaverton, OR 97006-6063<br>
Phone: (503) 578-7638<br>
FAX:      (503) 578-3228<br>
<br>
<br>

<p><font size="2" color="#800080">To:	</font><font size="2">&quot;YOSHIFUJI Hideaki / _$B5HF#1QL@&quot; &lt;yoshfuji@linux-ipv6.org&gt;</font><br>
<font size="2" color="#800080">cc:	</font><font size="2">Shirley Ma/Beaverton/IBM@IBMUS, mashirle@us.ltcfwd.linux.ibm.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org</font><font size="2" color="#800080"> </font><br>
<font size="2" color="#800080">Subject:	</font><font size="2">Re: [PATCH] IPv6 MIB:ipv6RouterAdvert netlink notification</font><br>
<br>
<br>
<font face="Courier New">On Fri, 16 Jan 2004 10:37:10 +0900 (JST)<br>
YOSHIFUJI Hideaki / _$B5HF#1QL@ &lt;yoshfuji@linux-ipv6.org&gt; wrote:<br>
<br>
&gt; In article &lt;OFB4F51C5A.FC479F2C-ON87256E1C.007B64B8@us.ibm.com&gt; (at Thu, 15 Jan 2004 14:31:47 -0800), Shirley Ma &lt;xma@us.ibm.com&gt; says:<br>
&gt; <br>
&gt; &gt; This patch is going to be used by SNMP for ipv6RouterAdvert Table. I will<br>
&gt; &gt; remove this Micro, and resubmit the patch.<br>
&gt; <br>
&gt; This patch is conceptually wrong.<br>
<br>
Ok, since this is controversial I'll back it out of my tree.<br>
</font><br>
<br>
</body></html>
--0__=08BBE48EDFF5A9108f9e8a93df938690918c08BBE48EDFF5A910--
