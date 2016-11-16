From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [BUG] X86: Removing inline decl on
 arch/x86/include/asm/desc.h.
Date: Wed, 16 Nov 2016 20:16:25 +0100 (CET)
Message-ID: <alpine.DEB.2.20.1611162005320.3697@nanos>
References: <1479239164-7721-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, Ingo Molnar <mingo@redhat.com>,
        "H. Peter Anvin" <hpa@zytor.com>,
        Realtek linux nic maintainers <nic_swsd@realtek.com>,
        x86@kernel.org, linux-kernel@vger.kernel.org
To: Corcodel Marian <asd@marian1000.go.ro>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479239164-7721-1-git-send-email-asd@marian1000.go.ro>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 Nov 2016, Corcodel Marian wrote:
>  Inline declarations suppress warning message from compiler but
>  most of these functions was declared static and is not used local on file.

Huch? This is a header file and the functions are marked inline on purpose.

Can you please explain what you are trying to achieve and why you think
that this is a good idea?

Thanks,

	tglx
