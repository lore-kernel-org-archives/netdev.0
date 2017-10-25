From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: atm/mpc: Stop using open-coded timer .data field
Date: Wed, 25 Oct 2017 13:08:53 +0900 (KST)
Message-ID: <20171025.130853.2178849004892038570.davem@davemloft.net>
References: <20171024084645.GA23963@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhumirks@gmail.com, akpm@linux-foundation.org, adobriyan@gmail.com,
        elena.reshetova@intel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171024084645.GA23963@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Tue, 24 Oct 2017 01:46:45 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using an explicit static variable to hold
> additional expiration details.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Bhumika Goyal <bhumirks@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Alexey Dobriyan <adobriyan@gmail.com>
> Cc: "Reshetova, Elena" <elena.reshetova@intel.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
