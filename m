From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created with
 no group
Date: Tue, 18 Mar 2014 17:10:38 +0200
Message-ID: <CAJZOPZLN0SmB7xcLXWOnC2GoDfGhJ5N-T1zA4S4Pg+ikqyFnig@mail.gmail.com>
References: <1395055050-20874-1-git-send-email-mike.rapoport@ravellosystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:52114 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932191AbaCRPKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 11:10:39 -0400
Received: by mail-pd0-f176.google.com with SMTP id r10so7227397pdi.35
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 08:10:38 -0700 (PDT)
In-Reply-To: <1395055050-20874-1-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 17, 2014 at 1:17 PM, Mike Rapoport
<mike.rapoport@ravellosystems.com> wrote:
> If the vxlan interface is created without group definition, there is a
> panic on the first packet reception:
>
> $ ip link add dev vxlan0 type vxlan id 1
> $ ip addr add dev vxlan0 10.0.0.1/24
> $ ip link set up dev vxlan0
>
>   BUG: unable to handle kernel paging request at 0000000100000103
>   IP: [<ffffffff8143435b>] ipv6_rcv+0xfa/0x399

Hi Mike,

So this bug/fix is for 3.14 and also earlier kernels?

Or.
