From: Anil Gunturu <anil.gunturu@gmail.com>
Subject: NETLINK_ROUTE sockets in kernel
Date: Tue, 2 Nov 2004 11:46:46 -0800
Message-ID: <2f61ba570411021146657f63f4@mail.gmail.com>
Reply-To: Anil Gunturu <anil.gunturu@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
I am trying to undestand the NETLINK_ROUTE protocol sockets on 2.4.18
kernel. Specifically, I am interested in knowing how the kernel
processes the netlink messages that it recieves from user space. I was
browsing the rtnetlink_rcv_msg (net/core/rtnetlink.c) function in the
kernel. But its not clear on how the rtnetlink_links array is
populated for PF_NETLINK family. rtnetlink_init seem to populate for
PF_PACKET and PF_UNSPEC.
Thanks,
-Anil
