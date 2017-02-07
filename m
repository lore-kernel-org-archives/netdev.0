From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/9] mlx4: order-0 allocations and page
 recycling
Date: Tue, 07 Feb 2017 08:28:52 -0800
Message-ID: <1486484932.7793.63.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170207030240.31357-1-edumazet@google.com>
         <3b996d14-0471-1fa3-e686-15cf48db4c19@gmail.com>
         <1486483592.7793.56.camel@edumazet-glaptop3.roam.corp.google.com>
         <1486484783.7793.61.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36326 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754088AbdBGQ2y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 11:28:54 -0500
Received: by mail-pg0-f66.google.com with SMTP id 75so12523112pgf.3
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 08:28:53 -0800 (PST)
In-Reply-To: <1486484783.7793.61.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-02-07 at 08:26 -0800, Eric Dumazet wrote:

> In most cases, using exactly 12 bytes per slot would allow better

typo : 24 bytes on 64bit arches.

(Instead of 128 bytes with the current implementation)

> packing. Only one cpu is using this area, no need to force strange
> alignments, for the sake of avoiding a multiply !
