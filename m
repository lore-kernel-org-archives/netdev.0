From: satya srikanth <satyasrikanth2001@yahoo.com>
Subject: gigabit ethernet
Date: Thu, 12 Feb 2004 00:39:15 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040212083915.73516.qmail@web21109.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sir,
    I need some help from you. I am using 2 xeon(2
GHz) machines each with two processors running linux
2.4.20-8smp kernel and having intel PRO/1000 gigabit
adapter NIC card(e1000 driver). I tried connecting
both of them using a gigabit switch. I am getting
gigabit speed only if I use my own TCP sockets sending
packets of size around 1400 bytes. If I send packets
of size around 500 bytes, I am getting maximum of only
500 Mbps. I noticed that NIC is receiving all the
packets but they are getting dropped in the kernel.
        I tried changing the settings like
netdev_max_backlog to 30000 and rmem_max, wmem_max and
txqueuelen, but of no use. Can you please suggest some
changes that I need to make to achieve this speed.
(Like changing number of Rx interrupts, Tx interrupts
etc). Can you please suggest some other links where I
can get some useful information. Will linux router
project LRP help me to achieve it.

        with regards,
        Satya Srikanth.

__________________________________
Do you Yahoo!?
Yahoo! Finance: Get your refund fast by filing online.
http://taxes.yahoo.com/filing.html
