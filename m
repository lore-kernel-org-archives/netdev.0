From: Adishesh M <adisheshsm@gmail.com>
Subject: adding ipv6 address manually in Linux
Date: Sat, 31 Mar 2012 02:27:09 +0530
Message-ID: <CA+f1OFr4_FiKxvSFWWGV1yQ-KPyRfFEnRcYxTZQhWiB0OdqBJQ@mail.gmail.com>
References: <CA+f1OFri1pvyn2n=L82bip+KEY4QnXEwPxNvy=23UOR4vDTzJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:49846 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760006Ab2C3U5L convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Mar 2012 16:57:11 -0400
Received: by lahj13 with SMTP id j13so1135103lah.19
        for <netdev@vger.kernel.org>; Fri, 30 Mar 2012 13:57:10 -0700 (PDT)
In-Reply-To: <CA+f1OFri1pvyn2n=L82bip+KEY4QnXEwPxNvy=23UOR4vDTzJQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

there some problem in linux if we send 'unsolicited Neighbor
Advertisement' =A0message for an ipv6 address as explained below.

Manually add a new ipv6 address in to a Linux machine and send
immediately 'unsolicited Neighbor Advertisement' then newly added
address is considered as duplicate ipv6 address.

usually if a new ipv6 address is added then Linux is sending '
Neighbor solicitation message in order to detect duplicate address. By =
some
how if i send unsolicited Neighbor advertisement message before linux
sends 'neighbor solicitation' message then linux is marking this
address as duplicate.

'ip -6 addr show' command output is
=A0inet6 2001:3333:5678:ddd1::55/64 scope global tentative dadfailed


why Linux is considering ipv6 address as duplicate if we send
unsolicited message?

if unsolicited message is sent after Linux completes duplicate address
detection procedure by using neighbor solicitation message then this
address is not considered as duplicate.


Regards,
Adishesh
