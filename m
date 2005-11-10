From: Mayuresh Chitale <mchitale@gmail.com>
Subject: does routing performance degrade from 2.4.20 to 2.4.31 ?
Date: Thu, 10 Nov 2005 16:12:29 +0600
Message-ID: <d096a3ee0511100212o6742f5a0t608c63cc9a35d8ae@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netfilter-bounces@lists.netfilter.org>
To: netdev@vger.kernel.org, netfilter@lists.netfilter.org
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter>,
	<mailto:netfilter-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter>
List-Post: <mailto:netfilter@lists.netfilter.org>
List-Help: <mailto:netfilter-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter>,
	<mailto:netfilter-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-bounces@lists.netfilter.org
Errors-To: netfilter-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Hi All,

We are working on kernel version 2.4.20 and are trying to migrate to
version 2.4.31. We are doing some performance related tests to see the
impact of migration. The routing throughput seems to degrade from
2.4.20 to 2.4.31.
We have a Malta board with mips 4kc processor and are using iperf tool
to do the testing. Two test PCs are connected to the malta and iperf
server is run on PC and the client on another PC. With netfilter
compiled into the kernel, version 2.4.20 shows better result than
2.4.31. No rules except the default (all accept) have been applied.
Without netfilter, both perform almost identical. Is this expected ??
The dump below shows the measurements. If anyone has done similar
tests before, please share with me their results.

Have a nice day.
Mayuresh.

2.4.31
=3D=3D=3D=3D=3D
[mayuresh@localhost ~]$ ./iperf -c 100.0.0.1 -P 2
------------------------------------------------------------
Client connecting to 100.0.0.1, TCP port 5001
TCP window size: 16.0 KByte (default)
------------------------------------------------------------
[  4] local 10.1.1.99 port 33702 connected with 100.0.0.1 port 5001
[  3] local 10.1.1.99 port 33701 connected with 100.0.0.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  16.9 MBytes  14.2 Mbits/sec
[  4]  0.0-10.0 sec  17.0 MBytes  14.2 Mbits/sec
[SUM]  0.0-10.0 sec  33.9 MBytes  28.3 Mbits/sec

2.4.20
=3D=3D=3D=3D=3D
[mayuresh@localhost ~]$ ./iperf -c 100.0.0.1 -P 2
------------------------------------------------------------
Client connecting to 100.0.0.1, TCP port 5001
TCP window size: 16.0 KByte (default)
------------------------------------------------------------
[  4] local 10.1.1.99 port 33705 connected with 100.0.0.1 port 5001
[  3] local 10.1.1.99 port 33704 connected with 100.0.0.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  20.2 MBytes  16.9 Mbits/sec
[  4]  0.0-10.0 sec  20.2 MBytes  16.9 Mbits/sec
[SUM]  0.0-10.0 sec  40.4 MBytes  33.8 Mbits/sec
