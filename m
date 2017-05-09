From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 0/2] net: Set maximum receive packet size on veth
 interfaces
Date: Tue, 9 May 2017 08:49:28 -0700
Message-ID: <20170509084928.4cfcbda5@xeon-e3>
References: <20170509124439.45674-1-fredrik.markstrom@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, bridge@lists.linux-foundation.org
To: Fredrik Markstrom <fredrik.markstrom@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33217 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754502AbdEIPtb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 11:49:31 -0400
Received: by mail-pf0-f173.google.com with SMTP id e193so2088320pfh.0
        for <netdev@vger.kernel.org>; Tue, 09 May 2017 08:49:30 -0700 (PDT)
In-Reply-To: <20170509124439.45674-1-fredrik.markstrom@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  9 May 2017 14:44:36 +0200
Fredrik Markstrom <fredrik.markstrom@gmail.com> wrote:

> Currently veth drops all packets larger then the mtu set on the receiving
> end of the pair. This is inconsistent with most hardware ethernet drivers.

There is no guarantee that packets larger than MTU + VLAN tag will be received
by hardware drivers. So why is this necessary for veth? What is your special
use case which makes this necessary?
