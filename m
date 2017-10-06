From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv6: remove unused err variable on
 icmpv6_push_pending_frames
Date: Thu, 05 Oct 2017 22:18:21 -0700 (PDT)
Message-ID: <20171005.221821.1101136936795374969.davem@davemloft.net>
References: <20171005194532.GA126147@debian>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        alexander.levin@one.verizon.com
To: devtimhansen@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171005194532.GA126147@debian>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tim Hansen <devtimhansen@gmail.com>
Date: Thu, 5 Oct 2017 15:45:32 -0400

> int err is unused by icmpv6_push_pending_frames(), this patch returns removes the variable and returns the function with 0.
> 
> git bisect shows this variable has been around since linux has been in git in commit 1da177e4c3f41524e886b7f1b8a0c1fc7321cac2.  
> 
> This was found by running make coccicheck M=net/ipv6/ on linus' tree on commit 77ede3a014a32746002f7889211f0cecf4803163 (current HEAD as of this patch).
> 
> Signed-off-by: Tim Hansen <devtimhansen@gmail.com>

Applied.
