From: Niranjan <niranjan_cs2905@yahoo.com>
Subject: Kernel Panic
Date: Tue, 10 Feb 2004 16:32:07 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040211003207.72643.qmail@web40708.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="0-2133023585-1076459527=:71922"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0-2133023585-1076459527=:71922
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id i1B0XaKO027961

Hi,
I am trying to add cryptoapi support in wireless LAN driver (linux-wlan-n=
g for Prism based card) for my security project. =20
While doing so, I am getting a kernel panic. I am not able to debug it as=
 there is no logging of any information related to kernel panic in the lo=
g files (/var/log/messages or /var/log/dmesg) when I reboot the system. I=
 have attached the log below available on the screen.
Can anyone please help me in what can be possible error by looking at the=
 log ?
I will greatly appreciate any help in this matter.

Regards,
-Niranjan
Research Assistant, UMASS.

Log available on the screen:

......
......
[<c01f5850>]  dev_queue_xmit           [kernel]            0x210  (0xc034=
de04))
[<c01f98ec>]   neigh_resolve_output    [kernel]            0xec     (0xc0=
34de1c))
                        neigh_update
                        neigh_lookup
                        arp_process
                        netif_receive_skb
                        process_backlog
                        net_rx_action
                        do_softirq
                        do_IRQ
                        call_do_IRQ
                        dump_fpu
                        apm_bios_call_simple
                        apm_do_idle
                        apm_cpu_idle
                        apm_cpu_idle
                        default_idle
                       cpu_idle
[<c01015000> stext                             [kernel]            0x0   =
   (0xc034dfe0))
=20
Code:   0f 0b e2 3f d7 25 c0 e9 77 fd ff ff 8d b4 26 00 00 00 00
 <0>Kernel Panic: Aiee, killing interrupt handler!
In interrupt handler =96 not syncing




---------------------------------
Do you Yahoo!?
Yahoo! Finance: Get your refund fast by filing online
--0-2133023585-1076459527=:71922
Content-Type: text/html; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id i1B0XaKO027961

<DIV>
<DIV>Hi,<BR>I am trying to add cryptoapi support&nbsp;in wireless LAN dri=
ver&nbsp;(linux-wlan-ng for Prism based card) for my security project.&nb=
sp;&nbsp;<BR>While doing so, I am getting a&nbsp;kernel panic. I am not a=
ble to debug it as&nbsp;there is no logging of any information related to=
 kernel panic in the log files (/var/log/messages or /var/log/dmesg) when=
 I reboot the system. I have attached the log below available on the scre=
en.<BR>Can anyone please help me in what can be possible error by looking=
 at the log ?</DIV>
<DIV>I will greatly appreciate any help in this matter.<BR><BR>Regards,<B=
R>-Niranjan<BR>Research Assistant, UMASS.</DIV>
<DIV><BR>Log available on the screen:<BR><BR>......<BR>......<BR>[&lt;c01=
f5850&gt;]&nbsp; dev_queue_xmit&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp; [kernel]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp; 0x210&nbsp; (0xc034de04))<BR>[&lt;c01f98ec&gt;]&nbsp=
;&nbsp; neigh_resolve_output&nbsp;&nbsp;&nbsp; [kernel]&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0xec&nbsp;&nbsp;&nbsp;&n=
bsp; (0xc034de1c))<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; neigh_update<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp; neigh_lookup<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
 arp_process<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp; netif_receive_skb<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp; process_backlog<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; net_rx_action<BR>&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; do_softirq<BR>&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; do_IRQ<BR>&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
 call_do_IRQ<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp; dump_fpu<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp; apm_bios_call_simple<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; apm_do_idle<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; apm_cpu_idle<BR>&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; apm_cpu_idle<BR>&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
 default_idle<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp; cpu_idle<BR>[&lt;c01015000&gt; stext&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [kernel]&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0x0&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; (0xc034dfe0))<BR>&nbsp;<BR>Code:&nbsp;&nbsp; 0f=
 0b e2 3f d7 25 c0 e9 77 fd ff ff 8d b4 26 00 00 00 00<BR>&nbsp;&lt;0&gt;=
Kernel Panic: Aiee, killing interrupt handler!<BR>In interrupt handler =96=
 not syncing<BR></DIV></DIV><p><hr SIZE=3D1>
Do you Yahoo!?<br>
Yahoo! Finance: <a href=3D"http://us.rd.yahoo.com/evt=3D22055/*http://tax=
es.yahoo.com/filing.html">Get your refund fast by filing online</a>
--0-2133023585-1076459527=:71922--
