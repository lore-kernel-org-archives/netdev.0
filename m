From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next] ipv4: fix tunneled VM traffic over hw VXLAN/GRE
 GSO NIC
Date: Sun, 22 Dec 2013 15:25:53 +0200
Message-ID: <CAJZOPZJsm08_EnGsitbx_qoHk28+TEnORJB__b9Zi284kcfkJw@mail.gmail.com>
References: <1387393368-1028-1-git-send-email-weichunc@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>
To: Wei-Chun Chao <weichunc@plumgrid.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:56387 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752414Ab3LVNZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 08:25:54 -0500
Received: by mail-pb0-f46.google.com with SMTP id md12so4401476pbc.33
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 05:25:53 -0800 (PST)
In-Reply-To: <1387393368-1028-1-git-send-email-weichunc@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 18, 2013 at 9:02 PM, Wei-Chun Chao <weichunc@plumgrid.com> wrote:
> This is also seen on 'net'.
>
> VM to VM GSO traffic is broken if it goes through VXLAN or GRE
> tunnel and the physical NIC on the host supports hardware VXLAN/GRE
> GSO offload (e.g. bnx2x and next-gen mlx4).

Ack, this patch solves the breakage of VM traffic that is subject to
offloaded vxlan traffic which I see with latest kernels and the mlx4
patches I posted last week. So how we make progress here, is this
patch getting in or the alternative suggested down the thread by
Wei-Chun here http://patchwork.ozlabs.org/patch/303025/?
