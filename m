From: David Shwatrz <dshwatrz@gmail.com>
Subject: Inconsistency in number of Unix sockets
Date: Mon, 29 Jun 2009 17:37:23 +0300
Message-ID: <31436f4a0906290737w7eba05a7r5e2ab96b4b2838a2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:63426 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753972AbZF2OhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 10:37:22 -0400
Received: by fg-out-1718.google.com with SMTP id e21so910437fga.17
        for <netdev@vger.kernel.org>; Mon, 29 Jun 2009 07:37:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On kernel 2.6.29.4-167: (Fedora 11):

Why is this inconsistency in number of Unix sockets, when running the following:

 cat /proc/net/protocols | grep UNIX
UNIX       432    986      -1   ....

lsof -U | wc -l
989

netstat --unix | wc -l
906

cat /proc/net/unix | wc -l
986

On which of this statistics should we rely when we want to know how
many Unix Domain sockets do we have ? There is a variable named unix_nr_socks,
but AFAIK, the patch which used it (for /proc/net/protocols ) was
reverted lately.

commit 1748376b6626acf59c24e9592ac67b3fe2a0e026
by Eric Dumazet <dada1@cosmosbay.com>

Regards,
DS
