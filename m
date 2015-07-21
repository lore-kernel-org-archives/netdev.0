From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH V2 net-next 0/3] ARM BPF JIT features
Date: Tue, 21 Jul 2015 08:53:05 -0700
Message-ID: <55AE6AE1.7030502@plumgrid.com>
References: <1437481000-22835-1-git-send-email-nschichan@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Russell King <linux@arm.linux.org.uk>
To: Nicolas Schichan <nschichan@freebox.fr>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Mircea Gherzan <mgherzan@gmail.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437481000-22835-1-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/21/15 5:16 AM, Nicolas Schichan wrote:
> This serie adds support for more instructions to the ARM BPF JIT
> namely skb netdevice type retrieval, skb payload offset retrieval, and
> skb packet type retrieval.
>
> This allows 35 tests to use the JIT instead of 29 before.
>
> This serie depends on the "BPF JIT fixes for ARM" serie sent earlier.

Actually in these patches I don't see a strong dependency on 'net' set,
but since you're saying there is, you'd need to resubmit this set after
your 'net' set is merged, whole 'net' sent to Linus and merged
into net-next.
