From: wu xiaofei <lampsu@gmail.com>
Subject: about packets forwarding
Date: Wed, 2 Sep 2009 17:03:42 +0800
Message-ID: <f4f837ab0909020203w67bcba16pbb317c587c58e70f@mail.gmail.com>
References: <f4f837ab0907220706g1129a1cbv7dfad944e5bada16@mail.gmail.com>
	 <f4f837ab0909020127o3359ed03j224ef51a0673bcd9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f204.google.com ([209.85.223.204]:50714 "EHLO
	mail-iw0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010AbZIBJDk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 05:03:40 -0400
Received: by iwn42 with SMTP id 42so299607iwn.33
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2009 02:03:43 -0700 (PDT)
In-Reply-To: <f4f837ab0909020127o3359ed03j224ef51a0673bcd9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have something to ask here.

The topology of the network is as follows.
There are six Nodes (A, B, C, D, M, N).

=A0 M
=A0 |
=A0 A
=A0/ \
B=A0=A0 D
=A0\ /
=A0 C
=A0 |
=A0 N

M-A, C-N are wired links.
A-B, B-C, A-D, D-C are wireless links.

Node M wnats to communicate with node N. Because the wireless links
are not very reliable, I want to forward the packets through A-B-C and
A-D-C simultaneously (When Node A receives packets(from Node M) from
its wired interface eth0, It will forward the same packets to its
wireless interfaces wlan0 and wlan1 simultaneously) . How to implement
this?

--
Regards,
=A0Wu
