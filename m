From: Jian Jun He <hejianj@cn.ibm.com>
Subject: RE: Fw: [Bugme-new] [Bug 4628] New: Test server hang while running rhr (network) test
 on RHEL4 with kernel 2.6.12-rc1-mm4
Date: Fri, 27 May 2005 00:09:31 +0800
Message-ID: <OFA06E9B66.53E35770-ON4825700D.00585BAF-4825700D.00589E4E@cn.ibm.com>
References: <468F3FDA28AA87429AD807992E22D07E056B8C25@orsmsx408>
Mime-Version: 1.0
Content-Type: multipart/related;
	Boundary="0__=C7BBFA9EDFCBDD3F8f9e8a93df938690918cC7BBFA9EDFCBDD3F"
Cc: "Andrew Morton" <akpm@osdl.org>, anton@samba.org,
        Dang En Ren <rende@cn.ibm.com>, ganesh.venkatesan@gmail.com,
        herbert@gondor.apana.org.au,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, jgarzik@pobox.com,
        Jia Sen Wang <wangjs@cn.ibm.com>,
        "Ronciak, John" <john.ronciak@intel.com>,
        Lei CDL Wang <cdlwangl@cn.ibm.com>,
        linuxppc64-dev@lists.linuxppc.org.sgi.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <468F3FDA28AA87429AD807992E22D07E056B8C25@orsmsx408>
To: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=C7BBFA9EDFCBDD3F8f9e8a93df938690918cC7BBFA9EDFCBDD3F
Content-type: multipart/alternative;
	Boundary="1__=C7BBFA9EDFCBDD3F8f9e8a93df938690918cC7BBFA9EDFCBDD3F"

--1__=C7BBFA9EDFCBDD3F8f9e8a93df938690918cC7BBFA9EDFCBDD3F
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: quoted-printable


hello Ganesh,

This is the detail information about the problem.I will verify the defe=
ct
on 2.6.12-rc5 with mm1 patch.
Thank you for your attention.

---------------------------------------
Distribution:
RHEL4 with kernel 2.6.12-rc1-mm4

Hardware Environment:
IBM OpenPower( CHRP IBM,9124-720 )

Software Environment:
RHEL4
RHR: rhr2-rhel4-1.0-14a.noarch.rpm

Problem Description:
The test server hang while running rhr (network) test on RHEL4 with ker=
nel
2.6.12-rc1-mm4.

Steps to reproduce:
1. Download kernel 2.6.12-rc1 and 2.6.12-rc1-mm4 patch from kernel.org,=

then
build the kernel on OpenPower 720
2. Download rhr2-rhel4-1.0-14a.noarch.rpm from rhn.redhat.com and insta=
ll
it on
the test machine.
3. Configure and run the rhr test via invoking redhat-ready.

Additional information:
Here is the backtrace from xmon.

3:mon> e
cpu 0x3: Vector: 700 (Program Check) at [c00000000ffe7920]
    pc: c00000000029632c: .__kfree_skb+0x188/0x240
    lr: c000000000296328: .__kfree_skb+0x184/0x240
    sp: c00000000ffe7ba0
   msr: 8000000000029032
  current =3D 0xc000000107f94040
  paca    =3D 0xc000000000431c00
    pid   =3D 0, comm =3D swapper
kernel BUG in __kfree_skb at net/core/skbuff.c:282!

3:mon> t
[c00000000ffe7c40] d0000000000ebac4 .e100_rx_clean_list+0xa0/0x144 [e10=
0]
[c00000000ffe7ce0] d0000000000ed6dc .e100_tx_timeout+0x7c/0xb0 [e100]
[c00000000ffe7d70] c0000000002b87bc .dev_watchdog+0xc8/0x154
[c00000000ffe7e00] c00000000006d6b4 .run_timer_softirq+0x180/0x298
[c00000000ffe7ed0] c0000000000667d8 .__do_softirq+0xdc/0x1b8
[c00000000ffe7f90] c000000000014bf0 .call_do_softirq+0x14/0x24
[c000000086b43860] c0000000000102c4 .do_softirq+0x98/0xac
[c000000086b438f0] c0000000000669cc .irq_exit+0x70/0x8c
[c000000086b43970] c000000000011fb8 .timer_interrupt+0x398/0x47c
[c000000086b43a90] c00000000000a2b4 decrementer_common+0xb4/0x100
--- Exception: 901 (Decrementer) at c000000000010554
.dedicated_idle+0x114/0x280
[c000000086b43e80] c0000000000108c8 .cpu_idle+0x3c/0x54
[c000000086b43f00] c00000000003cc8c .start_secondary+0x108/0x148
[c000000086b43f90] c00000000000bd84 .enable_64b_mode+0x0/0x28

Best Regards!

Jian Jun He

CSDL, Beijing
Email: hejianj@cn.ibm.com



                                                                       =
    
             "Venkatesan,                                              =
    
             Ganesh"                                                   =
    
             <ganesh.venkatesa                                         =
 To 
             n@intel.com>              "Andrew Morton" <akpm@osdl.org>,=
    
                                       Jian Jun He/China/Contr/IBM@IBMC=
N,  
             2005-05-26 21:00          "Ronciak, John"                 =
    
                                       <john.ronciak@intel.com>,       =
    
                                       "Brandeburg, Jesse"             =
    
                                       <jesse.brandeburg@intel.com>    =
    
                                                                       =
 cc 
                                       <ganesh.venkatesan@gmail.com>,  =
    
                                       <anton@samba.org>,              =
    
                                       <herbert@gondor.apana.org.au>,  =
    
                                       <jgarzik@pobox.com>,            =
    
                                       <linuxppc64-dev@lists.linuxppc.o=
rg. 
                                       sgi.com>, <netdev@oss.sgi.com>, =
    
                                       Dang En Ren/China/IBM@IBMCN, Jia=
    
                                       Sen Wang/China/IBM@IBMCN, Lei CD=
L   
                                       Wang/China/Contr/IBM@IBMCN      =
    
                                                                   Subj=
ect 
                                       RE: Fw: [Bugme-new] [Bug 4628] N=
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
    




Jian:

We need more information on the test you run to get this hang. We have
not seen a hang similar to the one you describe. We have a p-series
machine in our lab and all we need is details on the test to run.

Thanks,
Ganesh.

>-----Original Message-----
>From: Andrew Morton [mailto:akpm@osdl.org]
>Sent: Thursday, May 26, 2005 12:38 AM
>To: Jian Jun He; Ronciak, John; Venkatesan, Ganesh; Brandeburg, Jesse
>Cc: ganesh.venkatesan@gmail.com; anton@samba.org;
>herbert@gondor.apana.org.au; jgarzik@pobox.com; linuxppc64-
>dev@lists.linuxppc.org.sgi.com; netdev@oss.sgi.com; rende@cn.ibm.com;
>wangjs@cn.ibm.com; cdlwangl@cn.ibm.com
>Subject: Re: Fw: [Bugme-new] [Bug 4628] New: Test server hang while
running
>rhr (network) test on RHEL4 with kernel 2.6.12-rc1-mm4
>
>Jian Jun He <hejianj@cn.ibm.com> wrote:
>>
>> I download e100-3.4.8 and installed in the test machine (both client=

and
>>  server). But the server still hang while running rhr (network) test=
.
:(
>
>e100 is one of those drivers which we'd rather like to have working
>properly.
>
>Can we please confirm that a) this bug is not fixed in 2.6.12-rc5 and
b)
>nobody has seen a patch which fixes it?
>
>
>
>For reference:
>
>Herbert Xu <herbert@gondor.apana.org.au> wrote:
>>
>> Andrew Morton <akpm@osdl.org> wrote:
>> >
>> > Might be a bug in the e100 driver, might not be.
>> >
>> > I assume this is the
>> >
>> >        BUG_ON(skb->list !=3D NULL);
>>
>> It certainly is a bug in e100.
>>
>> e100_tx_timeout -> e100_down -> e100_rx_clean_list
>>
>> is racing against
>>
>> e100_poll -> e100_rx_clean -> e100_rx_indicate
>>
>> e100_rx_clean/e100_rx_indicate takes an skb off the RX ring and
>> while it's being processed e100_rx_clean_list comes along and
>> frees it.
>>
>> >From a quick check similar problems may exist in other drivers that=

>> have lockless ->poll() functions with RX rings.
=

--1__=C7BBFA9EDFCBDD3F8f9e8a93df938690918cC7BBFA9EDFCBDD3F
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline
Content-transfer-encoding: quoted-printable

<html><body>
<p>hello <tt>Ganesh</tt>,<br>
<br>
This is the detail information about the problem.I will verify the defe=
ct on 2.6.12-rc5 with mm1 patch. <br>
Thank you for your attention.<br>
<br>
---------------------------------------<br>
<tt><font size=3D"4">Distribution:<br>
RHEL4 with kernel 2.6.12-rc1-mm4<br>
<br>
Hardware Environment:<br>
IBM OpenPower( CHRP IBM,9124-720 )<br>
<br>
Software Environment:<br>
RHEL4<br>
RHR: rhr2-rhel4-1.0-14a.noarch.rpm<br>
<br>
Problem Description:<br>
The test server hang while running rhr (network) test on RHEL4 with ker=
nel <br>
2.6.12-rc1-mm4.<br>
<br>
Steps to reproduce:<br>
1. Download kernel 2.6.12-rc1 and 2.6.12-rc1-mm4 patch from kernel.org,=
 then <br>
build the kernel on OpenPower 720<br>
2. Download rhr2-rhel4-1.0-14a.noarch.rpm from rhn.redhat.com and insta=
ll it on <br>
the test machine.<br>
3. Configure and run the rhr test via invoking redhat-ready.<br>
<br>
Additional information:<br>
Here is the backtrace from xmon.<br>
<br>
3:mon&gt; e<br>
cpu 0x3: Vector: 700 (Program Check) at [c00000000ffe7920]<br>
 &nbsp; &nbsp;pc: c00000000029632c: .__kfree_skb+0x188/0x240<br>
 &nbsp; &nbsp;lr: c000000000296328: .__kfree_skb+0x184/0x240<br>
 &nbsp; &nbsp;sp: c00000000ffe7ba0<br>
 &nbsp; msr: 8000000000029032<br>
 &nbsp;current =3D 0xc000000107f94040<br>
 &nbsp;paca &nbsp; &nbsp;=3D 0xc000000000431c00<br>
 &nbsp; &nbsp;pid &nbsp; =3D 0, comm =3D swapper<br>
kernel BUG in __kfree_skb at net/core/skbuff.c:282!<br>
<br>
3:mon&gt; t<br>
[c00000000ffe7c40] d0000000000ebac4 .e100_rx_clean_list+0xa0/0x144 [e10=
0]<br>
[c00000000ffe7ce0] d0000000000ed6dc .e100_tx_timeout+0x7c/0xb0 [e100]<b=
r>
[c00000000ffe7d70] c0000000002b87bc .dev_watchdog+0xc8/0x154<br>
[c00000000ffe7e00] c00000000006d6b4 .run_timer_softirq+0x180/0x298<br>
[c00000000ffe7ed0] c0000000000667d8 .__do_softirq+0xdc/0x1b8<br>
[c00000000ffe7f90] c000000000014bf0 .call_do_softirq+0x14/0x24<br>
[c000000086b43860] c0000000000102c4 .do_softirq+0x98/0xac<br>
[c000000086b438f0] c0000000000669cc .irq_exit+0x70/0x8c<br>
[c000000086b43970] c000000000011fb8 .timer_interrupt+0x398/0x47c<br>
[c000000086b43a90] c00000000000a2b4 decrementer_common+0xb4/0x100<br>
--- Exception: 901 (Decrementer) at c000000000010554 .dedicated_idle+0x=
114/0x280<br>
[c000000086b43e80] c0000000000108c8 .cpu_idle+0x3c/0x54<br>
[c000000086b43f00] c00000000003cc8c .start_secondary+0x108/0x148<br>
[c000000086b43f90] c00000000000bd84 .enable_64b_mode+0x0/0x28</font></t=
t><br>
<br>
Best Regards!<br>
<br>
Jian Jun He<br>
<br>
CSDL, Beijing<br>
Email: hejianj@cn.ibm.com<br>
<br>
<img width=3D"16" height=3D"16" src=3D"cid:1__=3DC7BBFA9EDFCBDD3F8f9e8a=
93df938@cn.ibm.com" border=3D"0" alt=3D"Inactive hide details for &quot=
;Venkatesan, Ganesh&quot; &lt;ganesh.venkatesan@intel.com&gt;">&quot;Ve=
nkatesan, Ganesh&quot; &lt;ganesh.venkatesan@intel.com&gt;<br>
<br>
<br>

<table width=3D"100%" border=3D"0" cellspacing=3D"0" cellpadding=3D"0">=

<tr valign=3D"top"><td style=3D"background-image:url(cid:2__=3DC7BBFA9E=
DFCBDD3F8f9e8a93df938@cn.ibm.com); background-repeat: no-repeat; " widt=
h=3D"40%">
<ul>
<ul>
<ul>
<ul><b><font size=3D"2">&quot;Venkatesan, Ganesh&quot; &lt;ganesh.venka=
tesan@intel.com&gt;</font></b><font size=3D"2"> </font>
<p><font size=3D"2">2005-05-26 21:00</font></ul>
</ul>
</ul>
</ul>
</td><td width=3D"60%">
<table width=3D"100%" border=3D"0" cellspacing=3D"0" cellpadding=3D"0">=

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img width=3D"58"=
 height=3D"1" src=3D"cid:3__=3DC7BBFA9EDFCBDD3F8f9e8a93df938@cn.ibm.com=
" border=3D"0" alt=3D""><br>
<div align=3D"right"><font size=3D"2">To</font></div></td><td width=3D"=
100%"><img width=3D"1" height=3D"1" src=3D"cid:3__=3DC7BBFA9EDFCBDD3F8f=
9e8a93df938@cn.ibm.com" border=3D"0" alt=3D""><br>
<font size=3D"2">&quot;Andrew Morton&quot; &lt;akpm@osdl.org&gt;, Jian =
Jun He/China/Contr/IBM@IBMCN, &quot;Ronciak, John&quot; &lt;john.roncia=
k@intel.com&gt;, &quot;Brandeburg, Jesse&quot; &lt;jesse.brandeburg@int=
el.com&gt;</font></td></tr>

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img width=3D"58"=
 height=3D"1" src=3D"cid:3__=3DC7BBFA9EDFCBDD3F8f9e8a93df938@cn.ibm.com=
" border=3D"0" alt=3D""><br>
<div align=3D"right"><font size=3D"2">cc</font></div></td><td width=3D"=
100%"><img width=3D"1" height=3D"1" src=3D"cid:3__=3DC7BBFA9EDFCBDD3F8f=
9e8a93df938@cn.ibm.com" border=3D"0" alt=3D""><br>
<font size=3D"2">&lt;ganesh.venkatesan@gmail.com&gt;, &lt;anton@samba.o=
rg&gt;, &lt;herbert@gondor.apana.org.au&gt;, &lt;jgarzik@pobox.com&gt;,=
 &lt;linuxppc64-dev@lists.linuxppc.org.sgi.com&gt;, &lt;netdev@oss.sgi.=
com&gt;, Dang En Ren/China/IBM@IBMCN, Jia Sen Wang/China/IBM@IBMCN, Lei=
 CDL Wang/China/Contr/IBM@IBMCN</font></td></tr>

<tr valign=3D"top"><td width=3D"1%" valign=3D"middle"><img width=3D"58"=
 height=3D"1" src=3D"cid:3__=3DC7BBFA9EDFCBDD3F8f9e8a93df938@cn.ibm.com=
" border=3D"0" alt=3D""><br>
<div align=3D"right"><font size=3D"2">Subject</font></div></td><td widt=
h=3D"100%"><img width=3D"1" height=3D"1" src=3D"cid:3__=3DC7BBFA9EDFCBD=
D3F8f9e8a93df938@cn.ibm.com" border=3D"0" alt=3D""><br>
<font size=3D"2">RE: Fw: [Bugme-new] [Bug 4628] New: Test server hang w=
hile running rhr (network) test on RHEL4 with kernel 2.6.12-rc1-mm4</fo=
nt></td></tr>
</table>

<table border=3D"0" cellspacing=3D"0" cellpadding=3D"0">
<tr valign=3D"top"><td width=3D"58"><img width=3D"1" height=3D"1" src=3D=
"cid:3__=3DC7BBFA9EDFCBDD3F8f9e8a93df938@cn.ibm.com" border=3D"0" alt=3D=
""></td><td width=3D"336"><img width=3D"1" height=3D"1" src=3D"cid:3__=3D=
C7BBFA9EDFCBDD3F8f9e8a93df938@cn.ibm.com" border=3D"0" alt=3D""></td></=
tr>
</table>
</td></tr>
</table>
<br>
<tt>Jian:<br>
<br>
We need more information on the test you run to get this hang. We have<=
br>
not seen a hang similar to the one you describe. We have a p-series<br>=

machine in our lab and all we need is details on the test to run.<br>
<br>
Thanks,<br>
Ganesh.<br>
<br>
&gt;-----Original Message-----<br>
&gt;From: Andrew Morton [<a href=3D"mailto:akpm@osdl.org">mailto:akpm@o=
sdl.org</a>]<br>
&gt;Sent: Thursday, May 26, 2005 12:38 AM<br>
&gt;To: Jian Jun He; Ronciak, John; Venkatesan, Ganesh; Brandeburg, Jes=
se<br>
&gt;Cc: ganesh.venkatesan@gmail.com; anton@samba.org;<br>
&gt;herbert@gondor.apana.org.au; jgarzik@pobox.com; linuxppc64-<br>
&gt;dev@lists.linuxppc.org.sgi.com; netdev@oss.sgi.com; rende@cn.ibm.co=
m;<br>
&gt;wangjs@cn.ibm.com; cdlwangl@cn.ibm.com<br>
&gt;Subject: Re: Fw: [Bugme-new] [Bug 4628] New: Test server hang while=
<br>
running<br>
&gt;rhr (network) test on RHEL4 with kernel 2.6.12-rc1-mm4<br>
&gt;<br>
&gt;Jian Jun He &lt;hejianj@cn.ibm.com&gt; wrote:<br>
&gt;&gt;<br>
&gt;&gt; I download e100-3.4.8 and installed in the test machine (both =
client<br>
and<br>
&gt;&gt; &nbsp;server). But the server still hang while running rhr (ne=
twork) test.<br>
:(<br>
&gt;<br>
&gt;e100 is one of those drivers which we'd rather like to have working=
<br>
&gt;properly.<br>
&gt;<br>
&gt;Can we please confirm that a) this bug is not fixed in 2.6.12-rc5 a=
nd<br>
b)<br>
&gt;nobody has seen a patch which fixes it?<br>
&gt;<br>
&gt;<br>
&gt;<br>
&gt;For reference:<br>
&gt;<br>
&gt;Herbert Xu &lt;herbert@gondor.apana.org.au&gt; wrote:<br>
&gt;&gt;<br>
&gt;&gt; Andrew Morton &lt;akpm@osdl.org&gt; wrote:<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; Might be a bug in the e100 driver, might not be.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; I assume this is the<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; &nbsp; &nbsp; &nbsp; &nbsp;BUG_ON(skb-&gt;list !=3D NULL)=
;<br>
&gt;&gt;<br>
&gt;&gt; It certainly is a bug in e100.<br>
&gt;&gt;<br>
&gt;&gt; e100_tx_timeout -&gt; e100_down -&gt; e100_rx_clean_list<br>
&gt;&gt;<br>
&gt;&gt; is racing against<br>
&gt;&gt;<br>
&gt;&gt; e100_poll -&gt; e100_rx_clean -&gt; e100_rx_indicate<br>
&gt;&gt;<br>
&gt;&gt; e100_rx_clean/e100_rx_indicate takes an skb off the RX ring an=
d<br>
&gt;&gt; while it's being processed e100_rx_clean_list comes along and<=
br>
&gt;&gt; frees it.<br>
&gt;&gt;<br>
&gt;&gt; &gt;From a quick check similar problems may exist in other dri=
vers that<br>
&gt;&gt; have lockless -&gt;poll() functions with RX rings.<br>
</tt><br>
</body></html>=


--1__=C7BBFA9EDFCBDD3F8f9e8a93df938690918cC7BBFA9EDFCBDD3F--


--0__=C7BBFA9EDFCBDD3F8f9e8a93df938690918cC7BBFA9EDFCBDD3F
Content-type: image/gif;
	name="graycol.gif"
Content-Disposition: inline; filename="graycol.gif"
Content-ID: <1__=C7BBFA9EDFCBDD3F8f9e8a93df938@cn.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAAQAKECAMzMzAAAAP///wAAACH5BAEAAAIALAAAAAAQABAAAAIXlI+py+0PopwxUbpu
ZRfKZ2zgSJbmSRYAIf4fT3B0aW1pemVkIGJ5IFVsZWFkIFNtYXJ0U2F2ZXIhAAA7

--0__=C7BBFA9EDFCBDD3F8f9e8a93df938690918cC7BBFA9EDFCBDD3F
Content-type: image/gif;
	name="pic30027.gif"
Content-Disposition: inline; filename="pic30027.gif"
Content-ID: <2__=C7BBFA9EDFCBDD3F8f9e8a93df938@cn.ibm.com>
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

--0__=C7BBFA9EDFCBDD3F8f9e8a93df938690918cC7BBFA9EDFCBDD3F
Content-type: image/gif;
	name="ecblank.gif"
Content-Disposition: inline; filename="ecblank.gif"
Content-ID: <3__=C7BBFA9EDFCBDD3F8f9e8a93df938@cn.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAABAIAAAAAAAP///yH5BAEAAAEALAAAAAAQAAEAAAIEjI8ZBQA7

--0__=C7BBFA9EDFCBDD3F8f9e8a93df938690918cC7BBFA9EDFCBDD3F--
