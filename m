From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH net-next] ARM: net: support BPF_ALU | BPF_MOD
 instructions in the BPF JIT.
Date: Fri, 2 Oct 2015 15:49:39 +0100
Message-ID: <20151002144939.GZ21513@n2100.arm.linux.org.uk>
References: <1443796671-12598-1-git-send-email-nschichan@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Mircea Gherzan <mgherzan@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Nicolas Schichan <nschichan@freebox.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1443796671-12598-1-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 02, 2015 at 04:37:51PM +0200, Nicolas Schichan wrote:
> @@ -125,7 +125,7 @@ static u64 jit_get_skb_w(struct sk_buff *skb, int offset)
>  }
>  
>  /*
> - * Wrapper that handles both OABI and EABI and assures Thumb2 interworking
> + * Wrappers that handles both OABI and EABI and assures Thumb2 interworking

That doesn't read right with "wrapper" becoming plural.

"Wrapper that handles ..."

or

"Wrappers which handle ..."

As normal, I'll let David pick the patch up, but please adjust the above
comment first, thanks.

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
