From: Jian Jun He <hejianj@cn.ibm.com>
Subject: Re: Fw: [Bugme-new] [Bug 4628] New: Test server hang while running rhr (network) test
 on RHEL4 with kernel 2.6.12-rc1-mm4
Date: Wed, 25 May 2005 11:21:23 +0800
Message-ID: <OF705A70E2.EDC073EF-ON4825700C.00113C8B-4825700C.00124BB4@cn.ibm.com>
References: <5fc59ff305052411366b9b058c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/related;
	Boundary="0__=C7BBFA9FDF82BA1B8f9e8a93df938690918cC7BBFA9FDF82BA1B"
Cc: Andrew Morton <akpm@osdl.org>, Anton Blanchard <anton@samba.org>,
        linuxppc64-dev@lists.linuxppc.org.sgi.com, netdev@oss.sgi.com,
        Dang En Ren <rende@cn.ibm.com>, Lei CDL Wang <cdlwangl@cn.ibm.com>,
        Jia Sen Wang <wangjs@cn.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <5fc59ff305052411366b9b058c@mail.gmail.com>
To: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=C7BBFA9FDF82BA1B8f9e8a93df938690918cC7BBFA9FDF82BA1B
Content-type: multipart/alternative;
	Boundary="1__=C7BBFA9FDF82BA1B8f9e8a93df938690918cC7BBFA9FDF82BA1B"

--1__=C7BBFA9FDF82BA1B8f9e8a93df938690918cC7BBFA9FDF82BA1B
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: quoted-printable


"rhr" is a "Red Hat Certification Testing Suite". You can download it f=
rom
redhat.com.

Best Regards!

Jian Jun He

CSDL, Beijing
Email: hejianj@cn.ibm.com



                                                                       =
    
             Ganesh Venkatesan                                         =
    
             <ganesh.venkatesa                                         =
    
             n@gmail.com>                                              =
 To 
                                       Andrew Morton <akpm@osdl.org>   =
    
             2005-05-25 02:36                                          =
 cc 
                                       netdev@oss.sgi.com, Jian Jun    =
    
                                       He/China/Contr/IBM@IBMCN,       =
    
             Please respond to         linuxppc64-dev@lists.linuxppc.or=
g.s 
             Ganesh Venkatesan         gi.com, Anton Blanchard         =
    
                                       <anton@samba.org>               =
    
                                                                   Subj=
ect 
                                       Re: Fw: [Bugme-new] [Bug 4628] N=
ew: 
                                       Test server hang while running r=
hr  
                                       (network) test on RHEL4 with ker=
nel 
                                       2.6.12-rc1-mm4                  =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    
                                                                       =
    




Could you tell me what the rhr test is? Is this an IBM internal test to=
ol?


On 5/16/05, Andrew Morton <akpm@osdl.org> wrote:
>
> Might be a bug in the e100 driver, might not be.
>
> I assume this is the
>
>         BUG_ON(skb->list !=3D NULL);
>
> in __kfree_skb(), although the line number is off-by-one, and the
> .__kfree_skb+0x188/0x240 would tend to contradict that.  Anton, can y=
ou
> help work out where we went splat please?
>
> tx timeouts are fairly rare events, so this might not be a recently-a=
dded
> bug.
>
> Do we know if it is repeatable?
>
>
>
> Begin forwarded message:
>
> Date: Mon, 16 May 2005 02:44:04 -0700
> From: bugme-daemon@osdl.org
> To: bugme-new@lists.osdl.org
> Subject: [Bugme-new] [Bug 4628] New: Test server hang while running r=
hr
(network) test on RHEL4 with kernel 2.6.12-rc1-mm4
>
>
> http://bugme.osdl.org/show_bug.cgi?id=3D4628
>
>            Summary: Test server hang while running rhr (network) test=
 on
>                     RHEL4 with kernel 2.6.12-rc1-mm4
>     Kernel Version: 2.6.12-rc1 with mm4 patch
>             Status: NEW
>           Severity: normal
>              Owner: anton@samba.org
>          Submitter: hejianj@cn.ibm.com
>                 CC:
hanwenb@cn.ibm.com,mridge@us.ibm.com,rende@cn.ibm.com,wa
>                     ngjs@cn.ibm.com
>
>
> Distribution:
> RHEL4 with kernel 2.6.12-rc1-mm4
>
> Hardware Environment:
> IBM OpenPower( CHRP IBM,9124-720 )
>
> Software Environment:
> RHEL4
> RHR: rhr2-rhel4-1.0-14a.noarch.rpm
>
> Problem Description:
> The test server hang while running rhr (network) test on RHEL4 with
kernel
> 2.6.12-rc1-mm4.
>
> Steps to reproduce:
> 1. Download kernel 2.6.12-rc1 and 2.6.12-rc1-mm4 patch from kernel.or=
g,
then
> build the kernel on OpenPower 720
> 2. Download rhr2-rhel4-1.0-14a.noarch.rpm from rhn.redhat.com and ins=
tall
it on
> the test machine.
> 3. Configure and run the rhr test via invoking redhat-ready.
>
> Additional information:
> Here is the backtrace from xmon.
>
> 3:mon> e
> cpu 0x3: Vector: 700 (Program Check) at [c00000000ffe7920]
>     pc: c00000000029632c: .__kfree_skb+0x188/0x240
>     lr: c000000000296328: .__kfree_skb+0x184/0x240
>     sp: c00000000ffe7ba0
>    msr: 8000000000029032
>   current =3D 0xc000000107f94040
>   paca    =3D 0xc000000000431c00
>     pid   =3D 0, comm =3D swapper
> kernel BUG in __kfree_skb at net/core/skbuff.c:282!
>
> 3:mon> t
> [c00000000ffe7c40] d0000000000ebac4 .e100_rx_clean_list+0xa0/0x144 [e=
100]
> [c00000000ffe7ce0] d0000000000ed6dc .e100_tx_timeout+0x7c/0xb0 [e100]=

> [c00000000ffe7d70] c0000000002b87bc .dev_watchdog+0xc8/0x154
> [c00000000ffe7e00] c00000000006d6b4 .run_timer_softirq+0x180/0x298
> [c00000000ffe7ed0] c0000000000667d8 .__do_softirq+0xdc/0x1b8
> [c00000000ffe7f90] c000000000014bf0 .call_do_softirq+0x14/0x24
> [c000000086b43860] c0000000000102c4 .do_softirq+0x98/0xac
> [c000000086b438f0] c0000000000669cc .irq_exit+0x70/0x8c
> [c000000086b43970] c000000000011fb8 .timer_interrupt+0x398/0x47c
> [c000000086b43a90] c00000000000a2b4 decrementer_common+0xb4/0x100
> --- Exception: 901 (Decrementer) at c000000000010554
.dedicated_idle+0x114/0x280
> [c000000086b43e80] c0000000000108c8 .cpu_idle+0x3c/0x54
> [c000000086b43f00] c00000000003cc8c .start_secondary+0x108/0x148
> [c000000086b43f90] c00000000000bd84 .enable_64b_mode+0x0/0x28
>
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
>
>
=

--1__=C7BBFA9FDF82BA1B8f9e8a93df938690918cC7BBFA9FDF82BA1B
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline
Content-transfer-encoding: quoted-printable

<html><body>
<p>&quot;rhr&quot; is a &quot;Red Hat Certification Testing Suite&quot;=
. You can download it from redhat.com.<br>
<br>
Best Regards!<br>
<br>
Jian Jun He<br>
<br>
CSDL, Beijing<br>
Email: hejianj@cn.ibm.com<br>
<br>
<img width=3D"16" height=3D"16" src=3D"cid:1__=3DC7BBFA9FDF82BA1B8f9e8a=
93df938@cn.ibm.com" border=3D"0" alt=3D"Inactive hide details for Ganes=
h Venkatesan &lt;ganesh.venkatesan@gmail.com&gt;">Ganesh Venkatesan &lt=
;ganesh.venkatesan@gmail.com&gt;<br>
<br>
<br>

<table width=3D"100%" border=3D"0" cellspacing=3D"0" cellpadding=3D"0">=

<tr valign=3D"top"><td style=3D"background-image:url(cid:2__=3DC7BBFA9F=
DF82BA1B8f9e8a93df938@cn.ibm.com); background-repeat: no-repeat; " widt=
h=3D"40%">
<ul>
<ul>
<ul>
<ul><b><font size=3D"2">Ganesh Venkatesan &lt;ganesh.venkatesan@gmail.c=
om&gt;</font></b><font size=3D"2"> </font>
<p><font size=3D"2">2005-05-25 02:36</font>
<table border=3D"1">
<tr valign=3D"top"><td width=3D"168" bgcolor=3D"#FFFFFF"><div align=3D"=
center"><font size=3D"2">Please respond to<br>
Ganesh Venkatesan</font></div></td></tr>
</table>
</ul>
</ul>
</ul>
</ul>
</td><td width=3D"60%">
<table width=3D"100%" border=3D"0" cellspacing=3D"0" cellpadding=3D"0">=

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img width=3D"58"=
 height=3D"1" src=3D"cid:3__=3DC7BBFA9FDF82BA1B8f9e8a93df938@cn.ibm.com=
" border=3D"0" alt=3D""><br>
<div align=3D"right"><font size=3D"2">To</font></div></td><td width=3D"=
100%"><img width=3D"1" height=3D"1" src=3D"cid:3__=3DC7BBFA9FDF82BA1B8f=
9e8a93df938@cn.ibm.com" border=3D"0" alt=3D""><br>
<font size=3D"2">Andrew Morton &lt;akpm@osdl.org&gt;</font></td></tr>

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img width=3D"58"=
 height=3D"1" src=3D"cid:3__=3DC7BBFA9FDF82BA1B8f9e8a93df938@cn.ibm.com=
" border=3D"0" alt=3D""><br>
<div align=3D"right"><font size=3D"2">cc</font></div></td><td width=3D"=
100%"><img width=3D"1" height=3D"1" src=3D"cid:3__=3DC7BBFA9FDF82BA1B8f=
9e8a93df938@cn.ibm.com" border=3D"0" alt=3D""><br>
<font size=3D"2">netdev@oss.sgi.com, Jian Jun He/China/Contr/IBM@IBMCN,=
 linuxppc64-dev@lists.linuxppc.org.sgi.com, Anton Blanchard &lt;anton@s=
amba.org&gt;</font></td></tr>

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img width=3D"58"=
 height=3D"1" src=3D"cid:3__=3DC7BBFA9FDF82BA1B8f9e8a93df938@cn.ibm.com=
" border=3D"0" alt=3D""><br>
<div align=3D"right"><font size=3D"2">Subject</font></div></td><td widt=
h=3D"100%"><img width=3D"1" height=3D"1" src=3D"cid:3__=3DC7BBFA9FDF82B=
A1B8f9e8a93df938@cn.ibm.com" border=3D"0" alt=3D""><br>
<font size=3D"2">Re: Fw: [Bugme-new] [Bug 4628] New: Test server hang w=
hile running rhr (network) test on RHEL4 with kernel 2.6.12-rc1-mm4</fo=
nt></td></tr>
</table>

<table border=3D"0" cellspacing=3D"0" cellpadding=3D"0">
<tr valign=3D"top"><td width=3D"58"><img width=3D"1" height=3D"1" src=3D=
"cid:3__=3DC7BBFA9FDF82BA1B8f9e8a93df938@cn.ibm.com" border=3D"0" alt=3D=
""></td><td width=3D"336"><img width=3D"1" height=3D"1" src=3D"cid:3__=3D=
C7BBFA9FDF82BA1B8f9e8a93df938@cn.ibm.com" border=3D"0" alt=3D""></td></=
tr>
</table>
</td></tr>
</table>
<br>
<tt>Could you tell me what the rhr test is? Is this an IBM internal tes=
t tool?<br>
<br>
<br>
On 5/16/05, Andrew Morton &lt;akpm@osdl.org&gt; wrote:<br>
&gt; <br>
&gt; Might be a bug in the e100 driver, might not be.<br>
&gt; <br>
&gt; I assume this is the<br>
&gt; <br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; BUG_ON(skb-&gt;list !=3D NULL);<br>
&gt; <br>
&gt; in __kfree_skb(), although the line number is off-by-one, and the<=
br>
&gt; .__kfree_skb+0x188/0x240 would tend to contradict that. &nbsp;Anto=
n, can you<br>
&gt; help work out where we went splat please?<br>
&gt; <br>
&gt; tx timeouts are fairly rare events, so this might not be a recentl=
y-added<br>
&gt; bug.<br>
&gt; <br>
&gt; Do we know if it is repeatable?<br>
&gt; <br>
&gt; <br>
&gt; <br>
&gt; Begin forwarded message:<br>
&gt; <br>
&gt; Date: Mon, 16 May 2005 02:44:04 -0700<br>
&gt; From: bugme-daemon@osdl.org<br>
&gt; To: bugme-new@lists.osdl.org<br>
&gt; Subject: [Bugme-new] [Bug 4628] New: Test server hang while runnin=
g rhr (network) test on RHEL4 with kernel 2.6.12-rc1-mm4<br>
&gt; <br>
&gt; <br>
&gt; </tt><tt><a href=3D"http://bugme.osdl.org/show_bug.cgi?id=3D4628">=
http://bugme.osdl.org/show_bug.cgi?id=3D4628</a></tt><tt><br>
&gt; <br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Summary: Test server hang=
 while running rhr (network) test on<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nb=
sp; RHEL4 with kernel 2.6.12-rc1-mm4<br>
&gt; &nbsp; &nbsp; Kernel Version: 2.6.12-rc1 with mm4 patch<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Status: NEW<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Severity: normal<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Owner: anton@samba=
.org<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Submitter: hejianj@cn.ibm.com<br=
>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; CC: hanwen=
b@cn.ibm.com,mridge@us.ibm.com,rende@cn.ibm.com,wa<br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nb=
sp; ngjs@cn.ibm.com<br>
&gt; <br>
&gt; <br>
&gt; Distribution:<br>
&gt; RHEL4 with kernel 2.6.12-rc1-mm4<br>
&gt; <br>
&gt; Hardware Environment:<br>
&gt; IBM OpenPower( CHRP IBM,9124-720 )<br>
&gt; <br>
&gt; Software Environment:<br>
&gt; RHEL4<br>
&gt; RHR: rhr2-rhel4-1.0-14a.noarch.rpm<br>
&gt; <br>
&gt; Problem Description:<br>
&gt; The test server hang while running rhr (network) test on RHEL4 wit=
h kernel<br>
&gt; 2.6.12-rc1-mm4.<br>
&gt; <br>
&gt; Steps to reproduce:<br>
&gt; 1. Download kernel 2.6.12-rc1 and 2.6.12-rc1-mm4 patch from kernel=
.org, then<br>
&gt; build the kernel on OpenPower 720<br>
&gt; 2. Download rhr2-rhel4-1.0-14a.noarch.rpm from rhn.redhat.com and =
install it on<br>
&gt; the test machine.<br>
&gt; 3. Configure and run the rhr test via invoking redhat-ready.<br>
&gt; <br>
&gt; Additional information:<br>
&gt; Here is the backtrace from xmon.<br>
&gt; <br>
&gt; 3:mon&gt; e<br>
&gt; cpu 0x3: Vector: 700 (Program Check) at [c00000000ffe7920]<br>
&gt; &nbsp; &nbsp; pc: c00000000029632c: .__kfree_skb+0x188/0x240<br>
&gt; &nbsp; &nbsp; lr: c000000000296328: .__kfree_skb+0x184/0x240<br>
&gt; &nbsp; &nbsp; sp: c00000000ffe7ba0<br>
&gt; &nbsp; &nbsp;msr: 8000000000029032<br>
&gt; &nbsp; current =3D 0xc000000107f94040<br>
&gt; &nbsp; paca &nbsp; &nbsp;=3D 0xc000000000431c00<br>
&gt; &nbsp; &nbsp; pid &nbsp; =3D 0, comm =3D swapper<br>
&gt; kernel BUG in __kfree_skb at net/core/skbuff.c:282!<br>
&gt; <br>
&gt; 3:mon&gt; t<br>
&gt; [c00000000ffe7c40] d0000000000ebac4 .e100_rx_clean_list+0xa0/0x144=
 [e100]<br>
&gt; [c00000000ffe7ce0] d0000000000ed6dc .e100_tx_timeout+0x7c/0xb0 [e1=
00]<br>
&gt; [c00000000ffe7d70] c0000000002b87bc .dev_watchdog+0xc8/0x154<br>
&gt; [c00000000ffe7e00] c00000000006d6b4 .run_timer_softirq+0x180/0x298=
<br>
&gt; [c00000000ffe7ed0] c0000000000667d8 .__do_softirq+0xdc/0x1b8<br>
&gt; [c00000000ffe7f90] c000000000014bf0 .call_do_softirq+0x14/0x24<br>=

&gt; [c000000086b43860] c0000000000102c4 .do_softirq+0x98/0xac<br>
&gt; [c000000086b438f0] c0000000000669cc .irq_exit+0x70/0x8c<br>
&gt; [c000000086b43970] c000000000011fb8 .timer_interrupt+0x398/0x47c<b=
r>
&gt; [c000000086b43a90] c00000000000a2b4 decrementer_common+0xb4/0x100<=
br>
&gt; --- Exception: 901 (Decrementer) at c000000000010554 .dedicated_id=
le+0x114/0x280<br>
&gt; [c000000086b43e80] c0000000000108c8 .cpu_idle+0x3c/0x54<br>
&gt; [c000000086b43f00] c00000000003cc8c .start_secondary+0x108/0x148<b=
r>
&gt; [c000000086b43f90] c00000000000bd84 .enable_64b_mode+0x0/0x28<br>
&gt; <br>
&gt; ------- You are receiving this mail because: -------<br>
&gt; You are on the CC list for the bug, or are watching someone who is=
.<br>
&gt; <br>
&gt;<br>
</tt><br>
</body></html>=


--1__=C7BBFA9FDF82BA1B8f9e8a93df938690918cC7BBFA9FDF82BA1B--


--0__=C7BBFA9FDF82BA1B8f9e8a93df938690918cC7BBFA9FDF82BA1B
Content-type: image/gif;
	name="graycol.gif"
Content-Disposition: inline; filename="graycol.gif"
Content-ID: <1__=C7BBFA9FDF82BA1B8f9e8a93df938@cn.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAAQAKECAMzMzAAAAP///wAAACH5BAEAAAIALAAAAAAQABAAAAIXlI+py+0PopwxUbpu
ZRfKZ2zgSJbmSRYAIf4fT3B0aW1pemVkIGJ5IFVsZWFkIFNtYXJ0U2F2ZXIhAAA7

--0__=C7BBFA9FDF82BA1B8f9e8a93df938690918cC7BBFA9FDF82BA1B
Content-type: image/gif;
	name="pic29731.gif"
Content-Disposition: inline; filename="pic29731.gif"
Content-ID: <2__=C7BBFA9FDF82BA1B8f9e8a93df938@cn.ibm.com>
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

--0__=C7BBFA9FDF82BA1B8f9e8a93df938690918cC7BBFA9FDF82BA1B
Content-type: image/gif;
	name="ecblank.gif"
Content-Disposition: inline; filename="ecblank.gif"
Content-ID: <3__=C7BBFA9FDF82BA1B8f9e8a93df938@cn.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAABAIAAAAAAAP///yH5BAEAAAEALAAAAAAQAAEAAAIEjI8ZBQA7

--0__=C7BBFA9FDF82BA1B8f9e8a93df938690918cC7BBFA9FDF82BA1B--
