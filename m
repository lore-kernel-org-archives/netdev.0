From: Viral Mehta <Viral.Mehta@lntinfotech.com>
Subject: zero copy for relay server
Date: Mon, 28 Mar 2011 21:57:02 +0530
Message-ID: <D69C90565D53114396BF743585AF5A09122E61E9E7@VSHINMSMBX01.vshodc.lntinfotech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail96.messagelabs.com ([216.82.254.19]:3585 "EHLO
	mail96.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754739Ab1C1Q1R convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 12:27:17 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I am implementing a particular application where
my application acts nothing but like Relay Server.

Relay server accepts connection from machine A.
It also accepts connection from Machine B.

Machine A and B are on different LAN/subnnets.
Now, there are two connections.
What server is supposed to do is RECV packets from machine A and SEND same
to machine B.

Pseudo Code is something like,
while(1)
{
recvagain:
   n =3D recv(incoming_fd, &buf, 8192, ...)
   if(n < 0)
        goto recvagain;
   send(outgoing_fd, &buf, n, ...);
}

Now the question is,
I want to avoid kernel-user copy for such application.
I found that a syscall like "sendfile"; I wanted to know if there is any
similar thing exists in-kernel which can take 2 socket descriptors....

If not, is it possible ? I would like to implement the same if someone
can suggest some pointers.

Thanks,
Viral

The contents of this e-mail and any attachment(s) may contain confidential or privileged information for the intended recipient(s). Unintended recipients are prohibited from taking action on the basis of information in this e-mail and  using or disseminating the information,  and must notify the sender and delete it from their system. L&T Infotech will not accept responsibility or liability for the accuracy or completeness of, or the presence of any virus or disabling code in this e-mail"

______________________________________________________________________
