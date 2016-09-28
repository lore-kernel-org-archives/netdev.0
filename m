From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] net: ip, diag -- Add diag interface for raw sockets
Date: Wed, 28 Sep 2016 06:02:11 -0700
Message-ID: <1475067731.28155.92.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160928090357.GT1876@uranus.lan>
         <caef7649-9d25-6429-eeab-96c027d6cbc2@mojatatu.com>
         <20160928101726.GU1876@uranus.lan>
         <8293413c-a81d-f7ff-24f0-8f58ce877116@mojatatu.com>
         <20160928105147.GV1876@uranus.lan>
         <484dedaf-4e81-9a5a-ffb8-2c65b373c3a0@mojatatu.com>
         <20160928112703.GW1876@uranus.lan>
         <1475067432.28155.90.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1475067432.28155.90.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-09-28 at 05:57 -0700, Eric Dumazet wrote:

> Note that some programs could fail to compile with the added union
> anyway.
> 
> Some gcc versions are unable to compile a static init with an union
> 
> struct inet_diag_req_v2 foo = { .pad = 0, sdiag_family = AF_INET, };
> 
> When I cooked my recent fq commit I simply removed a pad and replaced
> it :
> 
> git show fefa569a9d4bc4 -- include

This is a bit different of course, since struct tc_fq_qd_stats is only
one way : Kernel produces the content and gives it to user space.

User space should probably not need to initialize such a structure, but
who knows what a programmer can write ;)
