From: "Michael T Kerrisk" <mtk-lists@gmx.net>
Subject: Re: asymmetry with MSG_DONTWAIT in sendmsg() and recvmsg()
Date: Thu, 8 Jul 2004 10:34:11 +0200 (MEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1525.1089275651@www62.gmx.net>
References: <40EBFDAE.8070903@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Friesen <cfriesen@nortelnetworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I have a SOCK_STREAM PF_UNIX socket with no special options enabled using
> fcntl().
> 
> The default with sendmsg() and recvmsg() is to block.
> 
> With sndmsg(), I can use the MSG_DONTWAIT flag to enable non-blocking
> operation for that one call.
> 
> How do I do the equivalent for recvmsg()?

MSG_DONTWAIT should also work with recvmsg().

Cheers

-- 
Michael Kerrisk
mtk-lists@gmx.net

"Sie haben neue Mails!" - Die GMX Toolbar informiert Sie beim Surfen!
Jetzt aktivieren unter http://www.gmx.net/info
