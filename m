From: Ricardo Landim <ricardolan@gmail.com>
Subject: (unknown)
Date: Fri, 21 Jun 2013 07:01:52 -0300
Message-ID: <CACYKsS63yKWVY=9P8hP198DdMV2KxZXXWKwCB0FTZsw4vu86Yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:54102 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751957Ab3FUKBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 06:01:53 -0400
Received: by mail-ob0-f169.google.com with SMTP id up14so8263157obb.28
        for <netdev@vger.kernel.org>; Fri, 21 Jun 2013 03:01:52 -0700 (PDT)
Subject: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

I am developing a RTP proxy for voip applications and tried use the
splice syscall
for zero copy. I am trying splice udp data to pipe and splice pipe to udp
socket.

I read some information of the splice function and reading the kernel
source code I saw this lines in net/ipv4/af_inet.c

const struct proto_ops inet_stream_ops = {
...
    .splice_read = tcp_splice_read,
...
}

const struct proto_ops inet_dgram_ops = {
...
...
}

There is an implementation of splice for TCP socket but not for UDP socket.

My question is: there is some limitation in UDP socket that prevents this
implementation?

Regards,
Ricardo Landim
