From: Buster Holzbauer <gnomish_barbarian@yahoo.com>
Subject: Checksum Question about new sk_buffs
Date: Wed, 22 Jul 2009 12:42:11 -0700 (PDT)
Message-ID: <362475.96996.qm@web30508.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web30508.mail.mud.yahoo.com ([68.142.200.121]:36076 "HELO
	web30508.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752263AbZGVTmL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2009 15:42:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello,

I am a researcher at a university working on a new protocol based off o=
f TCP, using the 2.6.26.5 kernel on a pair of gentoo machines. I need t=
o send additional sk_buffs containing redundancy information as well as=
 the sk_buffs TCP would normally send containing data.=A0

The redundancy sk_buffs are constructed by a function called by tcp_pus=
h (). I create these sk_buffs by calling sk_stream_alloc_skb(), then up=
dating a few fields in the header (such as sequence number), but I'm cl=
early doing something wrong or missing a step. I believe this because a=
fter adding a printk to the csum_error label in tcp_rcv_established, th=
e receiver-side logs show that these redundancy sk_buffs are triggering=
 this label. The normal data sk_buffs, as expected, do not trigger this=
 printk.

Does anyone have any information about the specific steps to create a n=
ew sk_buff, update header fields, and populate it with data so that the=
 receiver processes the sk_buff correctly?=A0

Thanks in advance for any help you can provide,
Buster Holzbauer




     =20
