From: Shirley Ma <xma@us.ibm.com>
Subject: Re: [PATCH]dump interface IPv6 multicast/anycast addresses through netlink
Date: Thu, 18 Mar 2004 23:16:52 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF3E88B8EA.382D75F6-ON87256E5C.00272BAC-88256E5C.0027A5ED@us.ibm.com>
References: <20040319.155536.20327066.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/related;
	Boundary="0__=08BBE4CFDFB4AD3C8f9e8a93df938690918c08BBE4CFDFB4AD3C"
Cc: davem@redhat.com, mashirle@us.ibm.com, netdev@oss.sgi.com,
        netdev-bounce@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040319.155536.20327066.yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=08BBE4CFDFB4AD3C8f9e8a93df938690918c08BBE4CFDFB4AD3C
Content-type: multipart/alternative;
	Boundary="1__=08BBE4CFDFB4AD3C8f9e8a93df938690918c08BBE4CFDFB4AD3C"

--1__=08BBE4CFDFB4AD3C8f9e8a93df938690918c08BBE4CFDFB4AD3C
Content-type: text/plain; charset=ISO-2022-JP
Content-transfer-encoding: quoted-printable






Thanks for your comments.

I am going to modify the patch,
removing RTM_NEWMULTICAST replaced by RTM_GETMULTICAST,
removing RTM_NEWANYCAST replaced by RTM_GETANYCAST.
IFA_MULTICAST must be added last!

RTM_NEWANYCAST could be added later for adding anycast
addresses through netlink as a seperate patch.

I will resubmit the patch after I come back from my vacation one week
later.

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
             pv6.org>                  mashirle@us.ltcfwd.linux.ibm.com=
    
             Sent by:                                                  =
 cc 
             netdev-bounce@oss         davem@redhat.com,               =
    
             .sgi.com                  netdev@oss.sgi.com, Shirley     =
    
                                       Ma/Beaverton/IBM@IBMUS,         =
    
                                       yoshfuji@linux-ipv6.org         =
    
             03/18/2004 10:55                                      Subj=
ect 
             PM                        Re: [PATCH]dump interface IPv6  =
    
                                       multicast/anycast addresses thro=
ugh 
                                       netlink                         =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    




In article <200403171130.30282.mashirle@us.ibm.com> (at Wed, 17 Mar 200=
4
11:30:30 -0800), Shirley Ma <mashirle@us.ibm.com> says:

> @@ -339,6 +345,7 @@
>            IFA_LOCAL,
>            IFA_LABEL,
>            IFA_BROADCAST,
> +          IFA_MULTICAST,
>            IFA_ANYCAST,
>            IFA_CACHEINFO
>  };

Please, please do not change IFA_XXX values.
You should put "IFA_MULTICAST" next to IFA_CACHEINFO.

--yoshfuji

=

--1__=08BBE4CFDFB4AD3C8f9e8a93df938690918c08BBE4CFDFB4AD3C
Content-type: text/html; charset=ISO-2022-JP
Content-Disposition: inline
Content-transfer-encoding: quoted-printable

<html><body>
<p>Thanks for your comments. <br>
<br>
I am going to modify the patch, <br>
removing RTM_NEWMULTICAST replaced by RTM_GETMULTICAST,<br>
removing RTM_NEWANYCAST replaced by RTM_GETANYCAST.<br>
IFA_MULTICAST must be added last!<br>
<br>
RTM_NEWANYCAST could be added later for adding anycast<br>
addresses through netlink as a seperate patch.<br>
<br>
I will resubmit the patch after I come back from my vacation one week l=
ater.<br>
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
<img src=3D"cid:10__=3D08BBE4CFDFB4AD3C8f9e8a93df938@us.ibm.com" width=3D=
"16" height=3D"16" alt=3D"Inactive hide details for YOSHIFUJI Hideaki /=
 =1B$B5HF#1QL@=1B(B &lt;yoshfuji@linux-ipv6.org&gt;">YOSHIFUJI Hideaki =
/ =1B$B5HF#1QL@=1B(B &lt;yoshfuji@linux-ipv6.org&gt;<br>
<br>
<br>

<table width=3D"100%" border=3D"0" cellspacing=3D"0" cellpadding=3D"0">=

<tr valign=3D"top"><td style=3D"background-image:url(cid:20__=3D08BBE4C=
FDFB4AD3C8f9e8a93df938@us.ibm.com); background-repeat: no-repeat; " wid=
th=3D"40%">
<ul>
<ul>
<ul>
<ul><b><font size=3D"2">YOSHIFUJI Hideaki / =1B$B5HF#1QL@=1B(B &lt;yosh=
fuji@linux-ipv6.org&gt;</font></b><font size=3D"2"> </font><br>
<font size=3D"2">Sent by: netdev-bounce@oss.sgi.com</font>
<p><font size=3D"2">03/18/2004 10:55 PM</font></ul>
</ul>
</ul>
</ul>
</td><td width=3D"60%">
<table width=3D"100%" border=3D"0" cellspacing=3D"0" cellpadding=3D"0">=

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img src=3D"cid:3=
0__=3D08BBE4CFDFB4AD3C8f9e8a93df938@us.ibm.com" border=3D"0" height=3D"=
1" width=3D"58" alt=3D""><br>
<div align=3D"right"><font size=3D"2">To</font></div></td><td width=3D"=
100%"><img src=3D"cid:30__=3D08BBE4CFDFB4AD3C8f9e8a93df938@us.ibm.com" =
border=3D"0" height=3D"1" width=3D"1" alt=3D""><br>
<font size=3D"2">mashirle@us.ltcfwd.linux.ibm.com</font></td></tr>

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img src=3D"cid:3=
0__=3D08BBE4CFDFB4AD3C8f9e8a93df938@us.ibm.com" border=3D"0" height=3D"=
1" width=3D"58" alt=3D""><br>
<div align=3D"right"><font size=3D"2">cc</font></div></td><td width=3D"=
100%"><img src=3D"cid:30__=3D08BBE4CFDFB4AD3C8f9e8a93df938@us.ibm.com" =
border=3D"0" height=3D"1" width=3D"1" alt=3D""><br>
<font size=3D"2">davem@redhat.com, netdev@oss.sgi.com, Shirley Ma/Beave=
rton/IBM@IBMUS, yoshfuji@linux-ipv6.org</font></td></tr>

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img src=3D"cid:3=
0__=3D08BBE4CFDFB4AD3C8f9e8a93df938@us.ibm.com" border=3D"0" height=3D"=
1" width=3D"58" alt=3D""><br>
<div align=3D"right"><font size=3D"2">Subject</font></div></td><td widt=
h=3D"100%"><img src=3D"cid:30__=3D08BBE4CFDFB4AD3C8f9e8a93df938@us.ibm.=
com" border=3D"0" height=3D"1" width=3D"1" alt=3D""><br>
<font size=3D"2">Re: [PATCH]dump interface IPv6 multicast/anycast addre=
sses through netlink</font></td></tr>
</table>

<table border=3D"0" cellspacing=3D"0" cellpadding=3D"0">
<tr valign=3D"top"><td width=3D"58"><img src=3D"cid:30__=3D08BBE4CFDFB4=
AD3C8f9e8a93df938@us.ibm.com" border=3D"0" height=3D"1" width=3D"1" alt=
=3D""></td><td width=3D"336"><img src=3D"cid:30__=3D08BBE4CFDFB4AD3C8f9=
e8a93df938@us.ibm.com" border=3D"0" height=3D"1" width=3D"1" alt=3D""><=
/td></tr>
</table>
</td></tr>
</table>
<br>
<tt>In article &lt;200403171130.30282.mashirle@us.ibm.com&gt; (at Wed, =
17 Mar 2004 11:30:30 -0800), Shirley Ma &lt;mashirle@us.ibm.com&gt; say=
s:<br>
<br>
&gt; @@ -339,6 +345,7 @@<br>
&gt; &nbsp;		 IFA_LOCAL,<br>
&gt; &nbsp;		 IFA_LABEL,<br>
&gt; &nbsp;		 IFA_BROADCAST,<br>
&gt; +		 IFA_MULTICAST,<br>
&gt; &nbsp;		 IFA_ANYCAST,<br>
&gt; &nbsp;		 IFA_CACHEINFO<br>
&gt; &nbsp;};<br>
<br>
Please, please do not change IFA_XXX values.<br>
You should put &quot;IFA_MULTICAST&quot; next to IFA_CACHEINFO.<br>
<br>
--yoshfuji<br>
<br>
</tt><br>
</body></html>=


--1__=08BBE4CFDFB4AD3C8f9e8a93df938690918c08BBE4CFDFB4AD3C--


--0__=08BBE4CFDFB4AD3C8f9e8a93df938690918c08BBE4CFDFB4AD3C
Content-type: image/gif;
	name="graycol.gif"
Content-Disposition: inline; filename="graycol.gif"
Content-ID: <10__=08BBE4CFDFB4AD3C8f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAAQAKECAMzMzAAAAP///wAAACH5BAEAAAIALAAAAAAQABAAAAIXlI+py+0PopwxUbpu
ZRfKZ2zgSJbmSRYAIf4fT3B0aW1pemVkIGJ5IFVsZWFkIFNtYXJ0U2F2ZXIhAAA7

--0__=08BBE4CFDFB4AD3C8f9e8a93df938690918c08BBE4CFDFB4AD3C
Content-type: image/gif;
	name="pic12001.gif"
Content-Disposition: inline; filename="pic12001.gif"
Content-ID: <20__=08BBE4CFDFB4AD3C8f9e8a93df938@us.ibm.com>
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

--0__=08BBE4CFDFB4AD3C8f9e8a93df938690918c08BBE4CFDFB4AD3C
Content-type: image/gif;
	name="ecblank.gif"
Content-Disposition: inline; filename="ecblank.gif"
Content-ID: <30__=08BBE4CFDFB4AD3C8f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAABAIAAAAAAAP///yH5BAEAAAEALAAAAAAQAAEAAAIEjI8ZBQA7

--0__=08BBE4CFDFB4AD3C8f9e8a93df938690918c08BBE4CFDFB4AD3C--
