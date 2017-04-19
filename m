From: Johannes Berg <johannes@sipsolutions.net>
Subject: __sk_buff.data_end
Date: Wed, 19 Apr 2017 23:31:00 +0200
Message-ID: <1492637460.22185.6.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:45834 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S967254AbdDSVbG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 17:31:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexei, Daniel,

I'm looking at adding the __wifi_sk_buff I talked about, and I notice
that it uses CB space to store data_end. Unfortunately, in a lot of
cases, we don't have any CB space to spare in wifi.

Is there any way to generate a series of instructions that instead does
the necessary calculations? I don't actually *see* such a way, because
I don't see how I could have a scratch register or scratch stack space,
but perhaps there's a way to do it?

johannes
