From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ARM: net: make BPF_LD | BPF_IND instruction
 trigger r_X initialisation to 0.
Date: Mon, 05 Oct 2015 07:01:55 -0700 (PDT)
Message-ID: <20151005.070155.1958954047126197017.davem@davemloft.net>
References: <1443793152-8661-1-git-send-email-nschichan@freebox.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@arm.linux.org.uk, mgherzan@gmail.com, daniel@iogearbox.net,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: nschichan@freebox.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443793152-8661-1-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Schichan <nschichan@freebox.fr>
Date: Fri,  2 Oct 2015 15:39:12 +0200

> Without this patch, if the only instructions using r_X are of the
> BPF_LD | BPF_IND type, r_X would not be reset to 0, using whatever
> value was there when entering the jited code. With this patch, r_X
> will be correctly marked as used so it will be reset to 0 in the
> prologue code.
> 
> This fix also makes the test "LD_IND byte default X" pass in the
> test_bpf module when the ARM JIT is enabled.
> 
> Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>

Applied.
