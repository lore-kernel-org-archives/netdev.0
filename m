From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: integer overflow in sctp_auth_create_key()
Date: Tue, 29 Nov 2011 01:19:32 -0500 (EST)
Message-ID: <20111129.011932.1501413448765180498.davem@davemloft.net>
References: <028246D6-9024-4E43-93A1-25A87878CBBC@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, vladislav.yasevich@hp.com,
	sri@us.ibm.com, linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	security@kernel.org
To: xi.wang@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <028246D6-9024-4E43-93A1-25A87878CBBC@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xi Wang <xi.wang@gmail.com>
Date: Tue, 22 Nov 2011 20:55:30 -0500

> The previous commit 30c2235c is incomplete and cannot prevent integer
> overflows. For example, when key_len is 0x80000000 (INT_MAX + 1), the
> left-hand side of the check, (INT_MAX - key_len), which is unsigned,
> becomes 0xffffffff (UINT_MAX) and bypasses the check.
> 
> Signed-off-by: Xi Wang <xi.wang@gmail.com>

Applied, but I had to apply your patch by hand because it was
corrupted by your email client.

Please fix this problem because I am not applying any other patch
you've submitted which has this issue.
