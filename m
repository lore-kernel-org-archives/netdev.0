From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: asymmetry with MSG_DONTWAIT in sendmsg() and recvmsg()
Date: Wed, 07 Jul 2004 09:42:06 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40EBFDAE.8070903@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I have a SOCK_STREAM PF_UNIX socket with no special options enabled using fcntl().

The default with sendmsg() and recvmsg() is to block.

With sndmsg(), I can use the MSG_DONTWAIT flag to enable non-blocking operation 
for that one call.

How do I do the equivalent for recvmsg()?

Thanks,

Chris
