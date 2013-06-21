From: Ricardo Landim <ricardolan@gmail.com>
Subject: UDP splice
Date: Fri, 21 Jun 2013 07:04:16 -0300
Message-ID: <CACYKsS7pMFNdBxU2raMphKyb1zU7MEbhc=vsD+FdZ5sgFq71NQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f52.google.com ([209.85.219.52]:38010 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725Ab3FUKER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 06:04:17 -0400
Received: by mail-oa0-f52.google.com with SMTP id g12so8977664oah.25
        for <netdev@vger.kernel.org>; Fri, 21 Jun 2013 03:04:17 -0700 (PDT)
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
