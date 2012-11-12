From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 1/9] net: core: use this_cpu_ptr per-cpu helper
Date: Mon, 12 Nov 2012 23:29:52 +0000
Message-ID: <0000013af6f524ea-0c223212-2fce-4162-83df-914fbc19c2cc-000000@email.amazonses.com>
References: <509C686F.20400@gmail.com> <0000013ae6c9e81a-eabe295b-72a5-4ebd-85c5-231bec1a70c5-000000@email.amazonses.com> <1352492144.19779.811.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Shan Wei <shanwei88@gmail.com>, David Miller <davem@davemloft.net>,
	timo.teras@iki.fi, steffen.klassert@secunet.com,
	NetDev <netdev@vger.kernel.org>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352492144.19779.811.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 9 Nov 2012, Eric Dumazet wrote:

> Its not the case.
>
> We need the _pointer_ to call :
>
> tasklet_schedule(tasklet);

Ah. Ok. In that case

Reviewed-by: Christoph Lameter <cl@linux.com>
