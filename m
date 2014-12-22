From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [RFC PATCH 00/17] fib_trie: Reduce time spent in fib_table_lookup
 by 35 to 75%
Date: Mon, 22 Dec 2014 10:59:46 -0800
Message-ID: <CAA93jw60daP2+_ZD-Yof08AOw2aN_cnBhTu0LW7e+fyb3_Jyng@mail.gmail.com>
References: <20141222172632.1119.51469.stgit@ahduyck-vm-fedora20>
	<CAA93jw7Zz8_wToKOou42mXhgunZypQ6f=oGEHZk2K6CbrsrNqg@mail.gmail.com>
	<54986514.1010502@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:33179 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754295AbaLVS7q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 13:59:46 -0500
Received: by mail-ob0-f182.google.com with SMTP id wo20so22339080obc.13
        for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 10:59:46 -0800 (PST)
In-Reply-To: <54986514.1010502@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 22, 2014 at 10:38 AM, Alexander Duyck
<alexander.h.duyck@redhat.com> wrote:

>> impressive. I think. But I don't quite understand what you mean by a=
 depth of 7?

>He means the deepest path in the fib_trie datastructure that is
>holding the routing table.

Thank you (dave and alexander)  for the clarification!

re:

cat /proc/net/fib_triestat
cat /proc/net/fib_trie

are these a newish feature or merely compiled out in openwrt?

I have to admit I would love to know what your improvements do for a
large (e.g. BGP) table in these regards. Regrettably they don=C2=B4t le=
t me
near those with pre-production code....


--=20
Dave T=C3=A4ht

http://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks
