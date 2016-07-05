From: Sargun Dhillon <sargun@sargun.me>
Subject: Backport bpf: try harder on clones when writing into skb? [Commit: 3697649ff29e0f647565eed04b27a7779c646a22]
Date: Tue, 5 Jul 2016 08:35:18 -0700
Message-ID: <CAMp4zn-MNgqJ1Xzm8JO529=LVyB71bdYaUm0FqyNCMx4Hf+xSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:33663 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755305AbcGEPf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 11:35:58 -0400
Received: by mail-oi0-f54.google.com with SMTP id u201so233891732oie.0
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 08:35:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Does it make sense to backport
3697649ff29e0f647565eed04b27a7779c646a22 from 4.6 to the longterm
(4.4) release? I can trivially recreate the issue represented by
3697649ff29e0f647565eed04b27a7779c646a22 by attaching a eBPF filter
that clones an ingress ICMP packet, and then tries to set the
destination MAC address.

It seems like the patch applies cleanly to 4.4. I cherry-picked it,
and rebuilt my kernel, and at least in the trivial test case passes.
