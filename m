From: Krishna Kumar <krkumar@us.ibm.com>
Subject: Question about netlink
Date: Tue, 08 Jul 2003 11:43:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F0B10E3.9050700@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Some of the netlink routines (eg rtnetlink_dump_ifinfo or inet6_dump_ifaddr) seem to get
user arguments from cb->args['n']. However I was not able to figure out where the
arguments are being set, can anyone help ?

netlink_dump_start() is where the cb gets allocated (initialized to 0), and that calls
netlink_dump(), which calls the assigned routine. I couldn't find where the args gets
initialized to user provided values. Any pointer to what to look for is very much
appreciated.

Thanks,

- KK
