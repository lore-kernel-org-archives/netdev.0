From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] sctp: fully initialize the IPv6 address in
 sctp_v6_to_addr()
Date: Tue, 15 Aug 2017 08:37:49 -0700
Message-ID: <1502811469.4936.84.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170814184304.82747-1-glider@google.com>
         <CAPA1RqDzSs3LogN+z69Ba2yoE6=jniobC-tEGd3TTh3z=39qxg@mail.gmail.com>
         <20170815015814.GB18688@localhost.localdomain>
         <20170814.194051.1408830683580606508.davem@davemloft.net>
         <20170815150557.GC18688@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        hideaki.yoshifuji@miraclelinux.com, glider@google.com,
        dvyukov@google.com, kcc@google.com, edumazet@google.com,
        lucien.xin@gmail.com, vyasevich@gmail.com,
        linux-kernel@vger.kernel.org, linux-sctp@vger.kernel.org,
        netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170815150557.GC18688@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-08-15 at 12:05 -0300, Marcelo Ricardo Leitner wrote:

> Ok, but I should see a difference in the generated code, right?

Depends on the compiler. Have you tried older versions ?

One argument is that following struct member definition eases code
review.

(It is easier to catch a field init is missing)
