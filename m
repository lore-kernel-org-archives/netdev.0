From: Andreas Schwab <schwab@linux-m68k.org>
Subject: Re: [RFC PATCH 1/1] BPF JIT for PPC64
Date: Sat, 25 Jun 2011 09:33:46 +0200
Message-ID: <m2boxmxt45.fsf@igel.home>
References: <4E04288F.4090201@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
To: Matt Evans <matt@ozlabs.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <4E04288F.4090201@ozlabs.org> (Matt Evans's message of "Fri, 24
	Jun 2011 16:02:55 +1000")
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Matt Evans <matt@ozlabs.org> writes:

> +	stdu	r1, -128(r1);					\

> +	addi	r5, r1, 128+BPF_PPC_STACK_BASIC+(2*8);		\

> +	addi	r1, r1, 128;					\

> +					PPC_STD(r_M + i, 1, -128 + (8*i));

> +					PPC_LD(r_M + i, 1, -128 + (8*i));

s/128/BPF_PPC_STACK_SAVE/?

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
