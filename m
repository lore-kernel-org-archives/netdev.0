From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net] net: ping: do not abuse udp_poll()
Date: Sun, 4 Jun 2017 10:54:03 +0900
Message-ID: <CAKD1Yr0-Lw1CBAWVvfw7EbF6K1tr7K6-BRfMBTYepuPhUQAAFQ@mail.gmail.com>
References: <20170603051742.m6jtztnn4b3me2co@sasha-lappy> <CANn89iKFcPwzVP_gfwkLND9ZTo-+PF8Ex1uePqaawTaLF=Qzmg@mail.gmail.com>
 <1496507365.5031.16.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Vasiliy Kulikov <segoon@openwall.com>,
        Solar Designer <solar@openwall.com>,
        "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>,
        "pabeni@redhat.com" <pabeni@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496507365.5031.16.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 4, 2017 at 1:29 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> The problem is that ping sockets should not use udp_poll() in the first
> place, and recent changes in UDP stack finally exposed this old bug.

Acked-By: Lorenzo Colitti <lorenzo@google.com>
Tested-By: Lorenzo Colitti <lorenzo@google.com>
