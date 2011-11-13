From: Miroslav Kratochvil <exa.exa@gmail.com>
Subject: tc: deleting single entry from filter hashtable
Date: Sun, 13 Nov 2011 22:19:49 +0100
Message-ID: <CAO0uZ+9N9zwt07EdQzz6KjGcpRT7rdmpaBvHoE0TLDXe-0kxMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:43477 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751976Ab1KMVTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2011 16:19:50 -0500
Received: by iage36 with SMTP id e36so6464374iag.19
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2011 13:19:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have following problem: For performance reasons I've been using a
setup known from LARTC as 'hashing filters', just like here:

http://lartc.org/howto/lartc.adv-filter.hashing.html

For the same performance reasons, I'd like to be able to delete or
change a _single_ entry from the hash table, so I don't need to refill
the whole table on every change I need to do (which can get pretty
slow for amount of entries over 10k, even when using a C program that
pushes the commands right into 'tc -batch')

Question: Is the single deletion/modification possible? If not --
judging from the lack of the documentation on given subject I kindof
expect that it's not possible -- is there any other possibility to
delete at least some reasonably small subset of the hash table that
could be modified and recreated quickly?

Also, here's my (failed) approach: I tried to assign different prio's
to all hashtable entries so they could be deleted by reference to that
prio, but after passing through TC they got created with the same prio
anyway..

Thanks for any help with this problem,

-mk
