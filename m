From: "J. Simonetti" <jeroen@simonetti.nl>
Subject: [PATCH 1/1] sysctl configurable icmperror sourceaddress
Date: Tue, 07 Jun 2005 11:26:23 +0200
Message-ID: <1118136384.10479.15.camel@jeroens.office.netland.nl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch alows you to change the source address of icmp error
messages. It applies cleanly to 2.6.11.11 and retains the default
behaviour.

In the old (default) behaviour icmp error messages are sent with the ip
of the exiting interface.
The new behaviour (when the sysctl variable is toggled on), it will send
the message with the ip of the interface that received the packet that
caused the icmp error. This is the behaviour network administrators will
expect from a router. It makes debugging complicated network layouts
much easier. Also, all 'vendor routers' I know of have the later
behaviour.

Regards,

Jeroen Simonetti
--
"Absolutely nothing should be concluded from these figures except that
no conclusion can be drawn from them."
(By Joseph L. Brothers, Linux/PowerPC Project)
