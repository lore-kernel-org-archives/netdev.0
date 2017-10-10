From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/core: Fix BUG to BUG_ON conditionals.
Date: Tue, 10 Oct 2017 12:32:52 -0700 (PDT)
Message-ID: <20171010.123252.2026981767835237524.davem@davemloft.net>
References: <20171009153759.km3lqss7hb72wrze@debian>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, edumazet@google.com, soheil@google.com,
        pabeni@redhat.com, elena.reshetova@intel.com, tom@quantonium.net,
        Jason@zx2c4.com, fw@strlen.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, alexander.levin@one.verizon.com
To: devtimhansen@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171009153759.km3lqss7hb72wrze@debian>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tim Hansen <devtimhansen@gmail.com>
Date: Mon, 9 Oct 2017 11:37:59 -0400

> Fix BUG() calls to use BUG_ON(conditional) macros.
> 
> This was found using make coccicheck M=net/core on linux next
> tag next-2017092
> 
> Signed-off-by: Tim Hansen <devtimhansen@gmail.com>

Althrough there were objections raised, none of them technically
stand up, and this does improve code generation for some
architectures, so I have applied this.

Thanks!
