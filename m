From: Shirley Ma <xma@us.ibm.com>
Subject: Re: [PATCH] IPv6 MIB:ipv6DefaultRouterTable
Date: Thu, 15 Jan 2004 10:26:21 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF87A9D639.F6A8D26B-ON88256E1C.0064AD99@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=07BBE48FDFF72B098f9e8a93df938690918c07BBE48FDFF72B09"
Cc: mashirle@us.ibm.com, davem@redhat.com, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE48FDFF72B098f9e8a93df938690918c07BBE48FDFF72B09
Content-type: text/plain; charset=ISO-2022-JP





This is a bug fix for ipDefaultRouter Table. According to the new IP MIBs,
the DefaultRouterLifeTime(expire) entry in this table is unsigned 32. It
measures the remaining length of time in seconds. If it's expire, the value
should be 0.

Thanks
Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone: (503) 578-7638
FAX:      (503) 578-3228



YOSHIFUJI Hideaki / 吉藤英明
<yoshfuji@linux-ipv6.org>@cerberus.hongo.wide.ad.jp> on 01/15/2004 01:03:15
AM

Sent by:    "Hideaki YOSHIFUJI" <yoshfuji@cerberus.hongo.wide.ad.jp>


To:    mashirle@us.ltcfwd.linux.ibm.com
cc:    davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, Shirley
       Ma/Beaverton/IBM@IBMUS
Subject:    Re: [PATCH] IPv6 MIB:ipv6DefaultRouterTable


In article <200401141622.09299.mashirle@us.ibm.com> (at Wed, 14 Jan 2004
16:22:09 -0800), Shirley Ma <mashirle@us.ibm.com> says:

> This patch is agaist 2.6.1 kernel.

Wrong. Do not change user interface.

--yoshfuji


--0__=07BBE48FDFF72B098f9e8a93df938690918c07BBE48FDFF72B09
Content-type: text/html; charset=ISO-2022-JP
Content-Disposition: inline

<html><body>
<p>This is a bug fix for ipDefaultRouter Table. According to the new IP MIBs, the DefaultRouterLifeTime(expire) entry in this table is unsigned 32. It measures the remaining length of time in seconds. If it's expire, the value should be 0.<br>
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

<p><font size="2" color="#800080">Sent by:	&quot;Hideaki YOSHIFUJI&quot; &lt;yoshfuji@cerberus.hongo.wide.ad.jp&gt;</font>
<p><font size="2" color="#800080">To:	</font><font size="2">mashirle@us.ltcfwd.linux.ibm.com</font><br>
<font size="2" color="#800080">cc:	</font><font size="2">davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, Shirley Ma/Beaverton/IBM@IBMUS</font><font size="2" color="#800080"> </font><br>
<font size="2" color="#800080">Subject:	</font><font size="2">Re: [PATCH] IPv6 MIB:ipv6DefaultRouterTable</font><br>
<br>
<br>
<font face="Courier New">In article &lt;200401141622.09299.mashirle@us.ibm.com&gt; (at Wed, 14 Jan 2004 16:22:09 -0800), Shirley Ma &lt;mashirle@us.ibm.com&gt; says:<br>
<br>
&gt; This patch is agaist 2.6.1 kernel.<br>
<br>
Wrong. Do not change user interface.<br>
<br>
--yoshfuji<br>
</font><br>
<br>
</body></html>
--0__=07BBE48FDFF72B098f9e8a93df938690918c07BBE48FDFF72B09--
