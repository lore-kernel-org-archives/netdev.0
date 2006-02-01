From: Ashutosh Naik <ashutosh.naik@gmail.com>
Subject: Re: [RFC] Poor Network Performance with e1000 on 2.6.14.3
Date: Wed, 1 Feb 2006 17:49:18 +0530
Message-ID: <81083a450602010419l16e6c2f2ldf1f87bff2582662@mail.gmail.com>
References: <81083a450601312117p391f1780g5bb25f5f90324f85@mail.gmail.com>
	 <43E04712.6080108@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_3046_27781836.1138796358412"
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030204AbWBAMTV@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-net@vger.kernel.org,
	Andrew Morton <akpm@osdl.org>, jgarzik@pobox.com
In-Reply-To: <43E04712.6080108@candelatech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_3046_27781836.1138796358412
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On 2/1/06, Ben Greear <greearb@candelatech.com> wrote:
> Ashutosh Naik wrote:
> > Now, I assume that on Gigabit ethernet, I should be getting Line Rate,
> > which is around 220 MBps. Even the CPU is not getting max-ed out here
> > and I am at a loss to understand this behaviour.
>
> Make sure you are running 64-bit 100+Mhz PCI, otherwise you will not
> get line speed.  ethtool -d [device]
> may get that info for you.

Thanks for that Ben. I now used a 64 bit,133 MHz PCI-X on both
machines and I got around  180 MBps, (86259.48 + 95164.90 ), which is
still a decent way away from Line speed. I think PCI is not a
bottleneck now, although I could be wrong. What could I be missing,
and has anybody seen line speed ( 220 MBps ) with e1000 ?

Regards and Thanks
Ashutosh

ps - Attaching my ettcp log

------=_Part_3046_27781836.1138796358412
Content-Type: text/plain; name=log.txt; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="log.txt"

[root@localhost ~]# ettcp -s -t -i 300ttcp-r: accept from 192.168.90.100
User: 17553  Nice: 0  System 8885  Idle:737051  Params:4

ttcp-t: buflen=65536, nbuf=2048, align=16384/0, port=5001  tcp  -> 192.168.90.10
0
nttcp-t: socket
nttcp-t: connect
User: 17555  Nice: 0  System 8892  Idle:737076  Params:4
^[
User: 19818  Nice: 0  System 14716  Idle:747604  Params:4
User_diff: 2265  Nice_diff: 0  System_diff: 5831  Idle_diff:10553 Tot:18649
User: 12.145423  System: 31.267092  Nice 0.000000  Idle:56.587485        
nttcp-r: Buflen:65536 SysLoad:31.27% 29232070656 bytes 299.97secs =95164.90 KB/s
ec
nttcp-r: 699884 I/O calls, msec/call = 0.44, calls/sec = 2333.15
nttcp-r: 0.2user 32.6sys 4:59real 10% 0i+0d 0maxrss 0+30pf 691228+3947csw
User: 19834  Nice: 0  System 14722  Idle:747623  Params:4
User_diff: 2279  Nice_diff: 0  System_diff: 5830  Idle_diff:10547 Tot:18656
User: 12.215909  System: 31.250000  Nice 0.000000  Idle:56.534091        
nttcp-t: Buflen:65536 SysLoad:31.25% 26499153920 bytes 300.00secs =86259.48 KB/s
ec
nttcp-t: 404345 I/O calls, msec/call = 0.76, calls/sec = 1347.80
nttcp-t: 0.2user 44.9sys 5:00real 15% 0i+0d 0maxrss 0+30pf 374765+1306csw
[1]+  Done                    ettcp -s -r -l 65536





------=_Part_3046_27781836.1138796358412--
