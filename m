From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] sctp: fully initialize the IPv6 address in
 sctp_v6_to_addr()
Date: Fri, 18 Aug 2017 16:01:46 -0700 (PDT)
Message-ID: <20170818.160146.1416785715146952456.davem@davemloft.net>
References: <20170816181640.40170-1-glider@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        marcelo.leitner@gmail.com, lucien.xin@gmail.com,
        vyasevich@gmail.com, hideaki.yoshifuji@miraclelinux.com,
        linux-kernel@vger.kernel.org, linux-sctp@vger.kernel.org,
        netdev@vger.kernel.org
To: glider@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170816181640.40170-1-glider@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Potapenko <glider@google.com>
Date: Wed, 16 Aug 2017 20:16:40 +0200

> KMSAN reported use of uninitialized sctp_addr->v4.sin_addr.s_addr and
> sctp_addr->v6.sin6_scope_id in sctp_v6_cmp_addr() (see below).
> Make sure all fields of an IPv6 address are initialized, which
> guarantees that the IPv4 fields are also initialized.
 ...
> Signed-off-by: Alexander Potapenko <glider@google.com>
> Reviewed-by: Xin Long <lucien.xin@gmail.com>
> Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied and queued up for -stable, thanks.
