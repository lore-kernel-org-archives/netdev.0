From: Darwin Dingel <darwin.dingel@gmail.com>
Subject: Inter-VRF routing on a single machine
Date: Tue, 12 Apr 2016 22:09:22 +1200
Message-ID: <CAAJwJQkfVWkdL+tOvcu5C9XBwTpNKcB8qvGeDUO32Tq6nW=xMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f49.google.com ([209.85.213.49]:36842 "EHLO
	mail-vk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755997AbcDLKJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 06:09:23 -0400
Received: by mail-vk0-f49.google.com with SMTP id c4so17614219vkb.3
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 03:09:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

Have anyone tried the following setup on a single machine with 2 TCP
sockets on different VRF's and succeeded?

- client_socket on VRF1
- server_socket on VRF2
- ip rules and iproutes for inter-VRF set up
- client_socket sends TCP connect to server_socket. skb was sent using
VRF1 interface
- skb received in loopback interface
- TCP code got SYN but cannot route back to VRF1 to send ACK.

I was wondering if this is a known limitation of VRF as of the moment,
or could work with proper iprules/iproute.


Thanks!

Darwin
