From: Shirley Ma <xma@us.ibm.com>
Subject: Re: [PATCH] IPv6 MIB:ipv6RouterAdvert netlink notification
Date: Fri, 16 Jan 2004 11:41:59 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF6E7E4DFA.6824D151-ON87256E1D.006A89B5@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=08BBE48EDFF90F258f9e8a93df938690918c08BBE48EDFF90F25"
Cc: davem@redhat.com, mashirle@us.ibm.com, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=08BBE48EDFF90F258f9e8a93df938690918c08BBE48EDFF90F25
Content-type: text/plain; charset=ISO-2022-JP
Content-transfer-encoding: quoted-printable






Yes. radvd should provide all these information. But radvd doesn't supp=
ort
this right now. I talked to someone who is patching SNMP to support new=
 IP
MIBs, he said it's better to support this through netlink, since netlin=
k
supports all other MIBs. Does netlink support user-user communication?

Anyway I will talk to radvd maintainers to ask them to support this if =
you
think this netlink notification is not needed.

Thanks
Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone: (503) 578-7638
FAX:      (503) 578-3228



YOSHIFUJI Hideaki / =1B$B5HF#1QL@=1B(B <yoshfuji@linux-ipv6.org>@oss.sg=
i.com on
01/16/2004 11:17:25 AM

Sent by:    netdev-bounce@oss.sgi.com


To:    Shirley Ma/Beaverton/IBM@IBMUS
cc:    davem@redhat.com, mashirle@us.ltcfwd.linux.ibm.com,
       kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, yoshfuji@linux-ipv6.or=
g
Subject:    Re: [PATCH] IPv6 MIB:ipv6RouterAdvert netlink notification


In article <OFDFE3736C.20FD7F98-ON87256E1D.00662F80@us.ibm.com> (at Fri=
, 16
Jan 2004 10:38:49 -0800), Shirley Ma <xma@us.ibm.com> says:

> But the patch is still needed for the Router, so it should be put in
> ndisc_router_discovery() when it's determined as a router. Are you OK=

with
> that?

I don't understand why it is needed.
radvd is respoinsible for those information.

--
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA


=

--0__=08BBE48EDFF90F258f9e8a93df938690918c08BBE48EDFF90F25
Content-type: text/html; charset=ISO-2022-JP
Content-Disposition: inline
Content-transfer-encoding: quoted-printable

<html><body>
<p>Yes. radvd should provide all these information. But radvd doesn't s=
upport this right now. I talked to someone who is patching SNMP to supp=
ort new IP MIBs, he said it's better to support this through netlink, s=
ince netlink supports all other MIBs. Does netlink support user-user co=
mmunication?<br>
<br>
Anyway I will talk to radvd maintainers to ask them to support this if =
you think this netlink notification is not needed.<br>
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

<p><font size=3D"2" color=3D"#800080">Sent by:	netdev-bounce@oss.sgi.co=
m</font>
<p><font size=3D"2" color=3D"#800080">To:	</font><font size=3D"2">Shirl=
ey Ma/Beaverton/IBM@IBMUS</font><br>
<font size=3D"2" color=3D"#800080">cc:	</font><font size=3D"2">davem@re=
dhat.com, mashirle@us.ltcfwd.linux.ibm.com, kuznet@ms2.inr.ac.ru, netde=
v@oss.sgi.com, yoshfuji@linux-ipv6.org</font><font size=3D"2" color=3D"=
#800080"> </font><br>
<font size=3D"2" color=3D"#800080">Subject:	</font><font size=3D"2">Re:=
 [PATCH] IPv6 MIB:ipv6RouterAdvert netlink notification</font><br>
<br>
<br>
<font face=3D"Courier New">In article &lt;OFDFE3736C.20FD7F98-ON87256E1=
D.00662F80@us.ibm.com&gt; (at Fri, 16 Jan 2004 10:38:49 -0800), Shirley=
 Ma &lt;xma@us.ibm.com&gt; says:<br>
<br>
&gt; But the patch is still needed for the Router, so it should be put =
in<br>
&gt; ndisc_router_discovery() when it's determined as a router. Are you=
 OK with<br>
&gt; that?<br>
<br>
I don't understand why it is needed.<br>
radvd is respoinsible for those information.<br>
<br>
-- <br>
Hideaki YOSHIFUJI @ USAGI Project &lt;yoshfuji@linux-ipv6.org&gt;<br>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA<br>
<br>
</font><br>
<br>
</body></html>=

--0__=08BBE48EDFF90F258f9e8a93df938690918c08BBE48EDFF90F25--
