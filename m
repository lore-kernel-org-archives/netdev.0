From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net-next: export skb_splice_bits()
Date: Thu, 23 May 2013 12:23:03 -0700 (PDT)
Message-ID: <20130523.122303.1335553698804467865.davem@davemloft.net>
References: <1369328974.3123.77.camel@Thor>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, pshelar@nicira.com,
	linux-kernel@vger.kernel.org
To: michel@digirati.com.br
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369328974.3123.77.camel@Thor>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ummm, no.

You don't export every single function just because it appears in a header
file.

When we have an in-kernel module that needs these functions, we can
export them, but no sooner.

So until you submit a set of changes that use these routines from modules
we're not exporting them.
