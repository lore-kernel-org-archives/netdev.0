From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: use designated initializers
Date: Sat, 17 Dec 2016 11:57:45 -0500 (EST)
Message-ID: <20161217.115745.140164763267728629.davem@davemloft.net>
References: <20161217005858.GA140223@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161217005858.GA140223@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Fri, 16 Dec 2016 16:58:58 -0800

> Prepare to mark sensitive kernel structures for randomization by making
> sure they're using designated initializers. These were identified during
> allyesconfig builds of x86, arm, and arm64, with most initializer fixes
> extracted from grsecurity.
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied, although "decnet: " would have been a much better
subsystem prefix.
