From: Xiaofei Wu <xiaofei_wu08@yahoo.com>
Subject: [iproute2]  tc pedit   modify  ethhdr ?
Date: Wed, 24 Mar 2010 05:31:47 -0700 (PDT)
Message-ID: <370745.69240.qm@web111619.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi <hadi@cyberus.ca>, linux netdev <netdev@vger.kernel.org>
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from n12.bullet.mail.ac4.yahoo.com ([74.6.228.92]:31092 "HELO
	n12.bullet.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755742Ab0CXMb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 08:31:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I want to modify  a packet's   h_dest and h_source in  structethhdr { } .

in   tc / m_pedit.c
------

36 explain(void)
37 {
38         fprintf(stderr, "Usage: ... pedit munge <MUNGE>\n");
39         fprintf(stderr,
40                 "Where: MUNGE := <RAW>|<LAYERED>\n"
41                 "\t<RAW>:= <OFFSETC>[ATC]<CMD>\n "
42                 "\t\tOFFSETC:= offset <offval> <u8|u16|u32>\n "
43                 "\t\tATC:= at <atval> offmask <maskval> shift <shiftval>\n "
44                 "\t\tNOTE: offval is byte offset, must be multiple of 4\n "
45                 "\t\tNOTE: maskval is a 32 bit hex number\n "
46                 "\t\tNOTE: shiftval is a is a shift value\n "
47                 "\t\tCMD:= clear | invert | set <setval>| retain\n "
48                 "\t<LAYERED>:= ip <ipdata> | ip6 <ip6data> \n "
49                 " \t\t| udp <udpdata> | tcp <tcpdata> | icmp <icmpdata> \n"
50                 "For Example usage look at the examples directory\n");
51 
52 }
------

OFFSETC:= offset <offval> <u8|u16|u32>
NOTE: offval is byte offset, must be multiple of 4

but the size of ethhdr is 14 bytes, 14 is not multiple of 4 .
How to use 'tc ... pedit ...'  modify  a packet's   h_dest and h_source 
of ethhdr ?
Use ' ... pedit munge offset -14 u16 set 0x0090 munge offset -12 u32 set 0x9600030a ... '   or 
use ' ... pedit munge offset -16 u32 ... munge offset -12  ... '  ?


--
Wu


      

