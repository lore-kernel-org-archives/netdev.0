From: "Mayuresh Chitale" <mchitale@gmail.com>
Subject: linux 2.6.16 routing problem
Date: Fri, 14 Jul 2006 17:55:10 +0530
Message-ID: <d096a3ee0607140525r3e1fb9dbg399c87bb3fbe4205@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-net-owner@vger.kernel.org>
To: netdev@vger.kernel.org, linux-net@vger.kernel.org
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

I am doing routing performance test using smartbits tester. The
traffic is pumped by smartapplications (that runs on smartbits).  I
see that the routing goes on for some time, then the fps(pps) value
starts dropping until it becomes zero. This is for rates less than
10Mb/s and packet size 64 bytes. But same thing happens with various
packet sizes such as 256, 1024 etc.

When debugging I see that the function ip_finish_output2 (in
net/ipv4/ip_output.c) calls hh->hh_output.

At the start of the test hh->hh_output calls dev_queue_xmit so routing
goes on fine.

Then suddenly it starts calling neigh_resolve_output after which pps
value starts gradually decreasing and it finally reaches zero.

If anyone has solved similar problem or knows what causes this
problem, please let me know.

Any suggestion is welcome.

Thanks,
Mayuresh.
