From: Shirley Ma <xma@us.ibm.com>
Subject: Re: ip addr flush hangs
Date: Tue, 9 Mar 2004 23:59:48 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF43AFDE87.2C15E199-ON87256E53.002BCBCB-88256E53.002BEDDC@us.ibm.com>
References: <20040310.123230.86301894.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/related;
	Boundary="0__=08BBE4C0DFB84D5B8f9e8a93df938690918c08BBE4C0DFB84D5B"
Cc: davem@redhat.com, netdev@oss.sgi.com, okir@suse.de,
        "Hideaki YOSHIFUJI" <yoshfuji@cerberus.hongo.wide.ad.jp>,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040310.123230.86301894.yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=08BBE4C0DFB84D5B8f9e8a93df938690918c08BBE4C0DFB84D5B
Content-type: multipart/alternative;
	Boundary="1__=08BBE4C0DFB84D5B8f9e8a93df938690918c08BBE4C0DFB84D5B"

--1__=08BBE4C0DFB84D5B8f9e8a93df938690918c08BBE4C0DFB84D5B
Content-type: text/plain; charset=ISO-2022-JP
Content-transfer-encoding: quoted-printable






OK, I will submit a patch for anycast and multicast addresses throught
different rtmsg.

Thanks
Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone: (503) 578-7638
FAX:      (503) 578-3228




                                                                       =
    
             YOSHIFUJI Hideaki                                         =
    
             / =1B$B5HF#1QL@=1B(B                                      =
              
             <yoshfuji@linux-i                                         =
 To 
             pv6.org>                  davem@redhat.com,               =
    
             Sent by: "Hideaki         netdev@oss.sgi.com, Shirley     =
    
             YOSHIFUJI"                Ma/Beaverton/IBM@IBMUS          =
    
             <yoshfuji@cerberu                                         =
 cc 
             s.hongo.wide.ad.j         okir@suse.de,                   =
    
             p>                        yoshfuji@linux-ipv6.org         =
    
                                                                   Subj=
ect 
                                       Re: ip addr flush hangs         =
    
             03/09/2004 07:32                                          =
    
             PM                                                        =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    




In article
<OF34091B26.07758A8E-ON87256E52.00833C04-88256E53.00004022@us.ibm.com> =
(at
Tue, 9 Mar 2004 15:56:00 -0800), Shirley Ma <xma@us.ibm.com> says:

> This fix causes a problem for SNMP IPv6 MIBs. It requires to dump all=

> interface
> address types unicast/mcast/anycast. I would like suggest to fix the =
ip
> command to fix the problem.

Grr... Putting anycast/multicast is not good idea.
(Sorry, I did not notice at that time...)

Anycast should use IFA_ANYCAST ifaddrmsg instead of IFA_ADDRESS.
Multicast should be provided in a different way (different rtmsg),
or use IFA_MULTICAST or something like that.

--yoshfuji
=

--1__=08BBE4C0DFB84D5B8f9e8a93df938690918c08BBE4C0DFB84D5B
Content-type: text/html; charset=ISO-2022-JP
Content-Disposition: inline
Content-transfer-encoding: quoted-printable

<html><body>
<p>OK, I will submit a patch for anycast and multicast addresses throug=
ht different rtmsg.<br>
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
<img src=3D"cid:10__=3D08BBE4C0DFB84D5B8f9e8a93df938@us.ibm.com" width=3D=
"16" height=3D"16" alt=3D"Inactive hide details for YOSHIFUJI Hideaki /=
 =1B$B5HF#1QL@=1B(B &lt;yoshfuji@linux-ipv6.org&gt;">YOSHIFUJI Hideaki =
/ =1B$B5HF#1QL@=1B(B &lt;yoshfuji@linux-ipv6.org&gt;<br>
<br>
<br>

<table width=3D"100%" border=3D"0" cellspacing=3D"0" cellpadding=3D"0">=

<tr valign=3D"top"><td style=3D"background-image:url(cid:20__=3D08BBE4C=
0DFB84D5B8f9e8a93df938@us.ibm.com); background-repeat: no-repeat; " wid=
th=3D"40%">
<ul>
<ul>
<ul>
<ul><b><font size=3D"2">YOSHIFUJI Hideaki / =1B$B5HF#1QL@=1B(B &lt;yosh=
fuji@linux-ipv6.org&gt;</font></b><font size=3D"2"> </font><br>
<font size=3D"2">Sent by: &quot;Hideaki YOSHIFUJI&quot; &lt;yoshfuji@ce=
rberus.hongo.wide.ad.jp&gt;</font>
<p><font size=3D"2">03/09/2004 07:32 PM</font></ul>
</ul>
</ul>
</ul>
</td><td width=3D"60%">
<table width=3D"100%" border=3D"0" cellspacing=3D"0" cellpadding=3D"0">=

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img src=3D"cid:3=
0__=3D08BBE4C0DFB84D5B8f9e8a93df938@us.ibm.com" border=3D"0" height=3D"=
1" width=3D"58" alt=3D""><br>
<div align=3D"right"><font size=3D"2">To</font></div></td><td width=3D"=
100%"><img src=3D"cid:30__=3D08BBE4C0DFB84D5B8f9e8a93df938@us.ibm.com" =
border=3D"0" height=3D"1" width=3D"1" alt=3D""><br>
<font size=3D"2">davem@redhat.com, netdev@oss.sgi.com, Shirley Ma/Beave=
rton/IBM@IBMUS</font></td></tr>

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img src=3D"cid:3=
0__=3D08BBE4C0DFB84D5B8f9e8a93df938@us.ibm.com" border=3D"0" height=3D"=
1" width=3D"58" alt=3D""><br>
<div align=3D"right"><font size=3D"2">cc</font></div></td><td width=3D"=
100%"><img src=3D"cid:30__=3D08BBE4C0DFB84D5B8f9e8a93df938@us.ibm.com" =
border=3D"0" height=3D"1" width=3D"1" alt=3D""><br>
<font size=3D"2">okir@suse.de, yoshfuji@linux-ipv6.org</font></td></tr>=


<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img src=3D"cid:3=
0__=3D08BBE4C0DFB84D5B8f9e8a93df938@us.ibm.com" border=3D"0" height=3D"=
1" width=3D"58" alt=3D""><br>
<div align=3D"right"><font size=3D"2">Subject</font></div></td><td widt=
h=3D"100%"><img src=3D"cid:30__=3D08BBE4C0DFB84D5B8f9e8a93df938@us.ibm.=
com" border=3D"0" height=3D"1" width=3D"1" alt=3D""><br>
<font size=3D"2">Re: ip addr flush hangs</font></td></tr>
</table>

<table border=3D"0" cellspacing=3D"0" cellpadding=3D"0">
<tr valign=3D"top"><td width=3D"58"><img src=3D"cid:30__=3D08BBE4C0DFB8=
4D5B8f9e8a93df938@us.ibm.com" border=3D"0" height=3D"1" width=3D"1" alt=
=3D""></td><td width=3D"336"><img src=3D"cid:30__=3D08BBE4C0DFB84D5B8f9=
e8a93df938@us.ibm.com" border=3D"0" height=3D"1" width=3D"1" alt=3D""><=
/td></tr>
</table>
</td></tr>
</table>
<br>
<tt>In article &lt;OF34091B26.07758A8E-ON87256E52.00833C04-88256E53.000=
04022@us.ibm.com&gt; (at Tue, 9 Mar 2004 15:56:00 -0800), Shirley Ma &l=
t;xma@us.ibm.com&gt; says:<br>
<br>
&gt; This fix causes a problem for SNMP IPv6 MIBs. It requires to dump =
all<br>
&gt; interface<br>
&gt; address types unicast/mcast/anycast. I would like suggest to fix t=
he ip<br>
&gt; command to fix the problem.<br>
<br>
Grr... Putting anycast/multicast is not good idea.<br>
(Sorry, I did not notice at that time...)<br>
<br>
Anycast should use IFA_ANYCAST ifaddrmsg instead of IFA_ADDRESS.<br>
Multicast should be provided in a different way (different rtmsg),<br>
or use IFA_MULTICAST or something like that.<br>
<br>
--yoshfuji<br>
</tt><br>
</body></html>=


--1__=08BBE4C0DFB84D5B8f9e8a93df938690918c08BBE4C0DFB84D5B--


--0__=08BBE4C0DFB84D5B8f9e8a93df938690918c08BBE4C0DFB84D5B
Content-type: image/gif;
	name="graycol.gif"
Content-Disposition: inline; filename="graycol.gif"
Content-ID: <10__=08BBE4C0DFB84D5B8f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAAQAKECAMzMzAAAAP///wAAACH5BAEAAAIALAAAAAAQABAAAAIXlI+py+0PopwxUbpu
ZRfKZ2zgSJbmSRYAIf4fT3B0aW1pemVkIGJ5IFVsZWFkIFNtYXJ0U2F2ZXIhAAA7

--0__=08BBE4C0DFB84D5B8f9e8a93df938690918c08BBE4C0DFB84D5B
Content-type: image/gif;
	name="pic27388.gif"
Content-Disposition: inline; filename="pic27388.gif"
Content-ID: <20__=08BBE4C0DFB84D5B8f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhWABDALP/AAAAAK04Qf79/o+Gm7WuwlNObwoJFCsoSMDAwGFsmIuezf///wAAAAAAAAAA
AAAAACH5BAEAAAgALAAAAABYAEMAQAT/EMlJq704682770RiFMRinqggEUNSHIchG0BCfHhOjAuh
EDeUqTASLCbBhQrhG7xis2j0lssNDopE4jfIJhDaggI8YB1sZeZgLVA9YVCpnGagVjV171aRVrYR
RghXcAGFhoUETwYxcXNyADJ3GlcSKGAwLwllVC1vjIUHBWsFilKQdI8GA5IcpApeJQt8L09lmgkH
LZikoU5wjqcyAMMFrJIDPAKvCFletKSev1HBw8KrxtjZ2tvc3d5VyKtCKW3jfz4uMKmq3xu4N0nK
BVoJQmx2LGVOmrqNjjJf2hHAQo/eDwJGTKhQMcgQEEAnEjFS98+RnW3smGkZU6ncCWav/4wYOnAI
TihRL/4FEwbp28BXMMcoscQCVxlepL4IGDSCyJyVQOu0o7CjmLN50OZlqWmyFy5/6yBBuji0AxFR
M00oQAqNIstqI6qKHUsWRAEAvagsmfUEAImyxgbmUpJk3IklNUtJOUAVLoUr1+wqDGTE4zk+T6FG
uQb3SizBCwatiiUgCBN8vrz+zFjVyQ8FWkOlg4NQiZMB5QS8QO3mpOaKnL0Z2EKvNMSILEThKhCg
zMKPVxYJh23qm9KNW7pArPynMqZDiErsTMqI+LRi3QAgkFUbXpuFKhSYZALd0O5RKa2z9EYKBbpb
qxIKsjUPRgD7I2XYV6wyrOw92ykExP8NW4URhknC5dKGE4v4NENQj2jXjmfNgOZDaXb5glRmXQ33
YEWQYNcZFnrYcIQLNzyTFDQNkXIff0ExVlY4srziQk43inZgL4rwxxINMvpFFAz1KOODHiu+4aEw
NEjFl5B3JIKWKF3k6I9bfUGp5ZZcdunll5IA4cuHvQQJ5gcsoCWOOUwgltIwAKRxJgbIkJAQZEq0
2YliZnpZZ4BH3CnYOXldOUOfQoYDqF1LFHbXCrO8xmRsfoXDXJ6ChjCAH3QlhJcT6VWE6FCkfCco
CgrMFsROrIEX3o2whVjWDjoJccN3LdggSGXLCdLEgHr1lyU3O3QxhgohNKXJCWv8JQr/PDdaqd6w
2rj1inLiGeiCJoDspAoQlYE6QWLSECehcWIYxIQES6zhbn1iImTHEQyqJ4eIxJJoUBc+3CbBuwZE
V5cJPPkIjFDdeEabQbd6WgICTxiiz0f5dBKquXF6k4senwEhYGnKEFJeGrxUZy8dB8gmAXI/sPvH
ESfCwVt5hTgYiqQqtdRNHQIU1PJ33ZqmzgE90OwLaoJcnMop1WiMmgkPHQRIrwgFuNV90A3doNKT
mrKIN07AnGcI9BQjhCBN4RfA1qIZnMqorJCogKfGQnxSCDilTVIA0yl5ciTovgLuBDKFUDE9aQcw
9SA+rjSNf9/M1gxrj6VwDTS0IUSElMzBfsj0NFXR2kwsV1A5IF1grLgLL/r1R40BZEnuBWgmQEyb
jqRwSAt6bqMCOFkvKFN2GPPkUzIm/SCF8z8pVzpbjVnMsy0vOr1hw3SaSRUhpY09v0z0J1FnwzPl
fmh+xl4WtR0zGu24I4KbMQm3lnVu2oNWxI9W/lcyzA+mCKF4DBikxb/+UWtOGRiFP8qEwAayIgIA
Ow==

--0__=08BBE4C0DFB84D5B8f9e8a93df938690918c08BBE4C0DFB84D5B
Content-type: image/gif;
	name="ecblank.gif"
Content-Disposition: inline; filename="ecblank.gif"
Content-ID: <30__=08BBE4C0DFB84D5B8f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAABAIAAAAAAAP///yH5BAEAAAEALAAAAAAQAAEAAAIEjI8ZBQA7

--0__=08BBE4C0DFB84D5B8f9e8a93df938690918c08BBE4C0DFB84D5B--
