From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip/ipvlan: enhance ability to add mode flags to
 existing modes
Date: Wed, 1 Nov 2017 22:18:22 +0100
Message-ID: <20171101221822.16f0af36@shemminger-XPS-13-9360>
References: <20171030205751.8280-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Changgong Li <chonggangli@google.com>,
        Mahesh Bandewar <maheshb@google.com>
To: Mahesh Bandewar <mahesh@bandewar.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:43592 "EHLO
        mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933690AbdKAVSt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 17:18:49 -0400
Received: by mail-lf0-f46.google.com with SMTP id a16so4068316lfk.0
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 14:18:48 -0700 (PDT)
In-Reply-To: <20171030205751.8280-1-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Oct 2017 13:57:51 -0700
Mahesh Bandewar <mahesh@bandewar.net> wrote:

> From: Mahesh Bandewar <maheshb@google.com>
> 
> IPvlan supported bridge-only functionality prior to commits
> a190d04db937 ('ipvlan: introduce 'private' attribute for all
> existing modes.') and fe89aa6b250c ('ipvlan: implement VEPA mode').
> These two commits allow to configure the VEPA and private modes now.
> This patch adds those options in ip command.
> 
> e.g.
>   bash:~# ip link add link eth0 name ipvl0 type ipvlan mode l2 private
>   -or-
>   bash:~# ip link add link eth0 type ipvl0 type ipvlan mode l2 vepa
> 
> Also the output will reflect the mode and the mode-flag accordingly.
> e.g.
>   bash:~# ip -details link show ipvl0
>   4: ipvl0@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc ...
>      link/ether 00:1a:11:44:a5:3e brd ff:ff:ff:ff:ff:ff promiscuity 0
>      ipvlan  mode l2 private addrgenmode eui64 numtxqueues 1 ...
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied to net-next branch (now that this is upstream).
Thanks Mahesh
