From: Krishna Kumar <kumarkr@us.ibm.com>
Subject: Re: crash in fib_hash_move
Date: Fri, 17 Sep 2004 11:47:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF3854E5A9.BFA6C434-ON88256F12.00671E99-88256F12.00672E21@us.ibm.com>
References: <20040917114249.7449b9ff@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/related;
	Boundary="0__=07BBE581DFF498098f9e8a93df938690918c07BBE581DFF49809"
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040917114249.7449b9ff@dell_ss3.pdx.osdl.net>
To: Stephen Hemminger <shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE581DFF498098f9e8a93df938690918c07BBE581DFF49809
Content-type: multipart/alternative;
	Boundary="1__=07BBE581DFF498098f9e8a93df938690918c07BBE581DFF49809"

--1__=07BBE581DFF498098f9e8a93df938690918c07BBE581DFF49809
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: quoted-printable






Probably the same problem checked in today by DM. See "Re: [TRIVIAL] Fi=
x
recent bug in fib_semantics.c".

- KK



                                                                       =
    
             Stephen Hemminger                                         =
    
             <shemminger@osdl.                                         =
    
             org>                                                      =
 To 
             Sent by:                  "David S. Miller"               =
    
             netdev-bounce@oss         <davem@redhat.com>              =
    
             .sgi.com                                                  =
 cc 
                                       netdev@oss.sgi.com              =
    
                                                                   Subj=
ect 
             09/17/2004 11:42          crash in fib_hash_move          =
    
             AM                                                        =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    




Current 2.6 tree is crashing on bootup in fib code.
Looks like recent FIB changes problem.

--------------

Unable to handle kernel paging request at virtual address 00003232
 printing eip:
*pde =3D 00000000
Oops: 0002 [#1]
PREEMPT SMP
Modules linked in: ext3 jbd DAC960 aic7xxx sd_mod scsi_mod
CPU:    5
EIP:    0060:[<c0278f14>]    Not tainted VLI
EFLAGS: 00010206   (2.6.9-rc2)
EIP is at fib_hash_move+0x90/0x146
eax: 0000322e   ebx: c316b480   ecx: 00000004   edx: f6cc5630
esi: c316b380   edi: f6cc5620   ebp: 00000000   esp: f6e0cd94
ds: 007b   es: 007b   ss: 0068
Process ifconfig (pid: 1507, threadinfo=3Df6e0c000 task=3Df6db0550)
Stack: 00000000 00000004 f6cc82e0 00000008 f6cc82e0 00000020 f6cc5620
c0279062
       00000020 00000001 00000000 ffffff97 f6e0ce40 f6e0ce90 ffffffea
f6e0ce40
       c314a980 f6cc6ec0 c027a8cd f6e0ce14 f6e0ce80 00000000 03ccf180
ffff14ac
Call Trace:
 [<c0279062>] fib_create_info+0x98/0x529
 [<c027a8cd>] fn_hash_insert+0xab/0x4d1
 [<c0278242>] fib_magic+0x104/0x129
 [<c02782f1>] fib_add_ifaddr+0x8a/0x12b
 [<c02785a7>] fib_inetaddr_event+0x47/0x53
 [<c0124da2>] notifier_call_chain+0x17/0x2b
 [<c02710a2>] inet_insert_ifa+0x8e/0x12b
 [<c0271950>] devinet_ioctl+0x317/0x60e
 [<c02738cb>] inet_ioctl+0x5b/0x8f
 [<c0230051>] sock_ioctl+0xdb/0x25b
 [<c014c55f>] fget+0x49/0x5e
 [<c015ba1c>] sys_ioctl+0xf5/0x24d
 [<c0105871>] sysenter_past_esp+0x52/0x71

=

--1__=07BBE581DFF498098f9e8a93df938690918c07BBE581DFF49809
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline
Content-transfer-encoding: quoted-printable

<html><body>
<p>Probably the same problem checked in today by DM. See &quot;Re: [TRI=
VIAL] Fix recent bug in fib_semantics.c&quot;.<br>
<br>
- KK<br>
<br>
<img src=3D"cid:10__=3D07BBE581DFF498098f9e8a93df938@us.ibm.com" width=3D=
"16" height=3D"16" alt=3D"Inactive hide details for Stephen Hemminger &=
lt;shemminger@osdl.org&gt;">Stephen Hemminger &lt;shemminger@osdl.org&g=
t;<br>
<br>
<br>

<table width=3D"100%" border=3D"0" cellspacing=3D"0" cellpadding=3D"0">=

<tr valign=3D"top"><td style=3D"background-image:url(cid:20__=3D07BBE58=
1DFF498098f9e8a93df938@us.ibm.com); background-repeat: no-repeat; " wid=
th=3D"40%">
<ul>
<ul>
<ul>
<ul><b><font size=3D"2">Stephen Hemminger &lt;shemminger@osdl.org&gt;</=
font></b><font size=3D"2"> </font><br>
<font size=3D"2">Sent by: netdev-bounce@oss.sgi.com</font>
<p><font size=3D"2">09/17/2004 11:42 AM</font></ul>
</ul>
</ul>
</ul>
</td><td width=3D"60%">
<table width=3D"100%" border=3D"0" cellspacing=3D"0" cellpadding=3D"0">=

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img src=3D"cid:3=
0__=3D07BBE581DFF498098f9e8a93df938@us.ibm.com" border=3D"0" height=3D"=
1" width=3D"58" alt=3D""><br>
<div align=3D"right"><font size=3D"2">To</font></div></td><td width=3D"=
100%"><img src=3D"cid:30__=3D07BBE581DFF498098f9e8a93df938@us.ibm.com" =
border=3D"0" height=3D"1" width=3D"1" alt=3D""><br>
<font size=3D"2">&quot;David S. Miller&quot; &lt;davem@redhat.com&gt;</=
font></td></tr>

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img src=3D"cid:3=
0__=3D07BBE581DFF498098f9e8a93df938@us.ibm.com" border=3D"0" height=3D"=
1" width=3D"58" alt=3D""><br>
<div align=3D"right"><font size=3D"2">cc</font></div></td><td width=3D"=
100%"><img src=3D"cid:30__=3D07BBE581DFF498098f9e8a93df938@us.ibm.com" =
border=3D"0" height=3D"1" width=3D"1" alt=3D""><br>
<font size=3D"2">netdev@oss.sgi.com</font></td></tr>

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img src=3D"cid:3=
0__=3D07BBE581DFF498098f9e8a93df938@us.ibm.com" border=3D"0" height=3D"=
1" width=3D"58" alt=3D""><br>
<div align=3D"right"><font size=3D"2">Subject</font></div></td><td widt=
h=3D"100%"><img src=3D"cid:30__=3D07BBE581DFF498098f9e8a93df938@us.ibm.=
com" border=3D"0" height=3D"1" width=3D"1" alt=3D""><br>
<font size=3D"2">crash in fib_hash_move</font></td></tr>
</table>

<table border=3D"0" cellspacing=3D"0" cellpadding=3D"0">
<tr valign=3D"top"><td width=3D"58"><img src=3D"cid:30__=3D07BBE581DFF4=
98098f9e8a93df938@us.ibm.com" border=3D"0" height=3D"1" width=3D"1" alt=
=3D""></td><td width=3D"336"><img src=3D"cid:30__=3D07BBE581DFF498098f9=
e8a93df938@us.ibm.com" border=3D"0" height=3D"1" width=3D"1" alt=3D""><=
/td></tr>
</table>
</td></tr>
</table>
<br>
<tt>Current 2.6 tree is crashing on bootup in fib code.<br>
Looks like recent FIB changes problem.<br>
<br>
--------------<br>
<br>
Unable to handle kernel paging request at virtual address 00003232<br>
 printing eip:<br>
*pde =3D 00000000<br>
Oops: 0002 [#1]<br>
PREEMPT SMP<br>
Modules linked in: ext3 jbd DAC960 aic7xxx sd_mod scsi_mod<br>
CPU: &nbsp; &nbsp;5<br>
EIP: &nbsp; &nbsp;0060:<c0278f14> &nbsp; &nbsp;Not tainted VLI<br>
EFLAGS: 00010206 &nbsp; (2.6.9-rc2)<br>
EIP is at fib_hash_move+0x90/0x146<br>
eax: 0000322e &nbsp; ebx: c316b480 &nbsp; ecx: 00000004 &nbsp; edx: f6c=
c5630<br>
esi: c316b380 &nbsp; edi: f6cc5620 &nbsp; ebp: 00000000 &nbsp; esp: f6e=
0cd94<br>
ds: 007b &nbsp; es: 007b &nbsp; ss: 0068<br>
Process ifconfig (pid: 1507, threadinfo=3Df6e0c000 task=3Df6db0550)<br>=

Stack: 00000000 00000004 f6cc82e0 00000008 f6cc82e0 00000020 f6cc5620 c=
0279062<br>
 &nbsp; &nbsp; &nbsp; 00000020 00000001 00000000 ffffff97 f6e0ce40 f6e0=
ce90 ffffffea f6e0ce40<br>
 &nbsp; &nbsp; &nbsp; c314a980 f6cc6ec0 c027a8cd f6e0ce14 f6e0ce80 0000=
0000 03ccf180 ffff14ac<br>
Call Trace:<br>
 <c0279062> fib_create_info+0x98/0x529<br>
 <c027a8cd> fn_hash_insert+0xab/0x4d1<br>
 <c0278242> fib_magic+0x104/0x129<br>
 <c02782f1> fib_add_ifaddr+0x8a/0x12b<br>
 <c02785a7> fib_inetaddr_event+0x47/0x53<br>
 <c0124da2> notifier_call_chain+0x17/0x2b<br>
 <c02710a2> inet_insert_ifa+0x8e/0x12b<br>
 <c0271950> devinet_ioctl+0x317/0x60e<br>
 <c02738cb> inet_ioctl+0x5b/0x8f<br>
 <c0230051> sock_ioctl+0xdb/0x25b<br>
 <c014c55f> fget+0x49/0x5e<br>
 <c015ba1c> sys_ioctl+0xf5/0x24d<br>
 <c0105871> sysenter_past_esp+0x52/0x71<br>
<br>
</tt><br>
</body></html>=


--1__=07BBE581DFF498098f9e8a93df938690918c07BBE581DFF49809--


--0__=07BBE581DFF498098f9e8a93df938690918c07BBE581DFF49809
Content-type: image/gif;
	name="graycol.gif"
Content-Disposition: inline; filename="graycol.gif"
Content-ID: <10__=07BBE581DFF498098f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAAQAKECAMzMzAAAAP///wAAACH5BAEAAAIALAAAAAAQABAAAAIXlI+py+0PopwxUbpu
ZRfKZ2zgSJbmSRYAIf4fT3B0aW1pemVkIGJ5IFVsZWFkIFNtYXJ0U2F2ZXIhAAA7

--0__=07BBE581DFF498098f9e8a93df938690918c07BBE581DFF49809
Content-type: image/gif;
	name="pic00286.gif"
Content-Disposition: inline; filename="pic00286.gif"
Content-ID: <20__=07BBE581DFF498098f9e8a93df938@us.ibm.com>
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

--0__=07BBE581DFF498098f9e8a93df938690918c07BBE581DFF49809
Content-type: image/gif;
	name="ecblank.gif"
Content-Disposition: inline; filename="ecblank.gif"
Content-ID: <30__=07BBE581DFF498098f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAABAIAAAAAAAP///yH5BAEAAAEALAAAAAAQAAEAAAIEjI8ZBQA7

--0__=07BBE581DFF498098f9e8a93df938690918c07BBE581DFF49809--
