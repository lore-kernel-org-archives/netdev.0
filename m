From: "Shekhar Kshirsagar" <shekhark@juniper.net>
Subject: 2.6 IPSec Throughput puzzle
Date: Tue, 28 Dec 2004 19:17:26 -0800
Message-ID: <EF311E6F9B0B0848A49ED20B06E9CB27031FDE77@gluon.jnpr.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Networking Team" <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, 

I have been trying to do some performance benchmarking for 2.6.10 IPSec
with 2.6 GHz P5s connected back-to-back with Gigabit connection. I'm
using iperf for performance test. 

I'm really puzzled with the performance results I'm getting. The
performance drop with AH seems high, but worst is performance drop with
null-esp in transport mode. Another strange observation is that DES
throughput is greater than null encryption throughput.

Throughput without IPSec	: 936 MBits/s ( 25% CPU Util)
Transport mode AH - SHA1      : 398 MBits/s (100% CPU Util)
Transport mode ESP - null/SHA1:  62 MBits/s (100% CPU Util) 
Transport mode ESP - des/SHA1 : 111 MBits/s (100% CPU Util)
Transport mode ESP - 3des/SHA1:  54 MBits/s (100% CPU Util)
Transport mode ESP - aes/SHA1 : 192 MBits/s (100% CPU Util)

Do these numbers sound reasonable?
(I don't have any iptable rules)

Thanks,
Shekhar
