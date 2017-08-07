From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC v2 3/5] samples/bpf: Fix inline asm issues building
 samples on arm64
Date: Mon, 07 Aug 2017 11:28:40 -0700 (PDT)
Message-ID: <20170807.112840.395506747161262549.davem@davemloft.net>
References: <20170807130602.31785-1-joelaf@google.com>
        <20170807130602.31785-4-joelaf@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, fengc@google.com,
        alison@she-devel.com, Juri.Lelli@arm.com, ast@kernel.org,
        daniel@iogearbox.net, netdev@vger.kernel.org
To: joelaf@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170807130602.31785-4-joelaf@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please, no.

The amount of hellish hacks we are adding to deal with this is getting
way out of control.

BPF programs MUST have their own set of asm headers, this is the
only way to get around this issue in the long term.

I am also strongly against adding -static to the build.
