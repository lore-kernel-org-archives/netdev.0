From: Johannes Berg <johannes@sipsolutions.net>
Subject: eBPF - little-endian load instructions?
Date: Tue, 11 Apr 2017 12:38:34 +0200
Message-ID: <1491907114.31620.18.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
        Alexei Starovoitov <ast@kernel.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:49294 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753756AbdDKKil (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 06:38:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Looking at (e)BPF for wifi, I notice that everything is big endian in
loads from the frame - and wifi is all little endian.

Obviously, this can be worked around by doing byte-loads and swapping
in the program, but it'll be more efficient to not do that.

Do you think it's possible to add little-endian load instructions? Or
perhaps there should be a conversion function from BE to LE?

Thanks,
johannes
