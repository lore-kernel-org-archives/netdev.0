From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: r8169: panic on 2.6.11
Date: Fri, 04 Mar 2005 22:34:16 -0800
Message-ID: <422952E8.6010801@osdl.org>
References: <20050304132804.270cf05b@dxpl.pdx.osdl.net> <20050304154903.7b7e0fb1@dxpl.pdx.osdl.net> <20050305003735.GE1148@electric-eye.fr.zoreil.com> <200503042303.50055.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Jon Mason <jdmason@us.ibm.com>
In-Reply-To: <200503042303.50055.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The packet burst is 10 million 64 byte packets. Could be the sender
or switch causing merging, but I suspect the r8169 on the slow receiver.

Details are:
# cat /proc/net/pktgen/eth0
Params: count 10000000  min_pkt_size: 60  max_pkt_size: 60
      frags: 0  delay: 0  clone_skb: 1000000  ifname: eth0
      flows: 0 flowlen: 0
      dst_min: 172.2.251.143  dst_max:
      src_min:   src_max:
      src_mac: 00:0D:60:53:08:18  dst_mac: 00:09:5B:BD:B1:F9
      udp_src_min: 9  udp_src_max: 9  udp_dst_min: 9  udp_dst_max: 9
      src_mac_count: 0  dst_mac_count: 0
      Flags:
Current:
      pkts-sofar: 10000000  errors: 6374336
      started: 1109979805822722us  stopped: 1109979815051630us idle: 
166364us
      seq_num: 10000011  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
      cur_saddr: 0x670114ac  cur_daddr: 0x8ffb02ac
      cur_udp_dst: 9  cur_udp_src: 9
      flows: 0
Result: OK: 9228908(c9062544+d166364) usec, 10000000 (60byte,0frags)
   1083551pps 520Mb/sec (520104480bps) errors: 6374336
