From: Shirley Ma <xma@us.ibm.com>
Subject: Re: [PATCH]Add new IPv6 MIBs counters support through netlink
Date: Wed, 26 May 2004 16:32:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFA97F4753.DC8C93AD-ON87256EA0.0080DAAB-07256EA0.00814B08@us.ibm.com>
References: <20040527.080828.06774575.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="=_alternative 00814B0407256EA0_="
Cc: davem@redhat.com, mashirle@us.ibm.com, netdev@oss.sgi.com,
        "Hideaki YOSHIFUJI" <yoshfuji@cerberus.hongo.wide.ad.jp.sgi.com>,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040527.080828.06774575.yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multipart message in MIME format.
--=_alternative 00814B0407256EA0_=
Content-Type: text/plain; charset="US-ASCII"

Hi,Yoshifuji

        Thanks for you comments!

> Without adding support for u64 counter, it does not make sense to add
> new interface. You can add new counter to the end of the structures.

It's not good to add new counters to the end of the old structure. The mib 

number and offset will be wrong.

>This also contains per-interface statistics support.
(I rember that you said that) we should add idev into an route and avoid
get/put idev.

Only a few get/put idev there, not too many. And in some places there are 
no 
route, no we can't use idev in route.

> I strongly do not want to poeple to change their code twice to support
draft-ietf-ipv6-rfc2011-update-XX.txt.

All the counters not just IP will be eventually 64 bits. We can fix it 
later. And 
if we implement 64 counters here, there is performance issue on some 
architectures which don't support atmoic 64 for 32 bit platform.

Thanks
Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone: (503) 578-7638
FAX:      (503) 578-3228


--=_alternative 00814B0407256EA0_=
Content-Type: text/html; charset="US-ASCII"


<br><font size=2><tt>Hi,Yoshifuji</tt></font>
<br>
<br><font size=2><tt>&nbsp; &nbsp; &nbsp; &nbsp; Thanks for you
comments!</tt></font>
<br>
<br><font size=2><tt>&gt; Without adding support for u64 counter, it does
not make sense to add<br>
&gt; new interface. You can add new counter to the end of the structures.<br>
</tt></font>
<br><font size=2><tt>It's not good to add new counters to the end of the
old structure. The mib </tt></font>
<br><font size=2><tt>number and offset will be wrong.</tt></font>
<br><font size=2><tt><br>
&gt;This also contains per-interface statistics support.<br>
(I rember that you said that) we should add idev into an route and avoid<br>
get/put idev.<br>
</tt></font>
<br><font size=2><tt>Only a few get/put idev there, not too many. And in
some places there are no </tt></font>
<br><font size=2><tt>route, no we can't use idev in route.</tt></font>
<br><font size=2><tt><br>
&gt; I strongly do not want to poeple to change their code twice to support<br>
draft-ietf-ipv6-rfc2011-update-XX.txt.<br>
<br>
All the counters not just IP will be eventually 64 bits. We can fix it
later. And </tt></font>
<br><font size=2><tt>if we implement 64 counters here, there is performance
issue on some </tt></font>
<br><font size=2><tt>architectures which don't support atmoic 64 for 32
bit platform.</tt></font>
<br>
<br><font size=2 face="sans-serif">Thanks<br>
Shirley Ma<br>
IBM Linux Technology Center<br>
15300 SW Koll Parkway<br>
Beaverton, OR 97006-6063<br>
Phone: (503) 578-7638<br>
FAX: &nbsp; &nbsp; &nbsp;(503) 578-3228<br>
<br>
</font>
--=_alternative 00814B0407256EA0_=--
