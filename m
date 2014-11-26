From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] x86: bpf_jit_comp: simplify trivial boolean return
Date: Wed, 26 Nov 2014 18:55:48 +0100
Message-ID: <54761424.8060203@redhat.com>
References: <CAADnVQK8mn4ZHwbhBArosEw3Bmsc5vJfOzAeRE3R_1S7dbNfkg@mail.gmail.com> <1417021108.19695.5.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Quentin Lambert <lambert.quentin@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417021108.19695.5.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/26/2014 05:58 PM, Joe Perches wrote:
...
>> imo existing code is fine and I don't think the time spent
>> reviewing such changes is worth it when there is no
>> improvement in readability.

+1

> Is there any value in reordering these tests for frequency
> or maybe using | instead of || to avoid multiple jumps?

No, it's not a fast-path.
