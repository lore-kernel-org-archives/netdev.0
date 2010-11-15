From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: guard the size of the nf_ct_ext
Date: Mon, 15 Nov 2010 12:10:05 +0100
Message-ID: <4CE1150D.1080302@trash.net>
References: <1289801749-8993-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1289801749-8993-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15.11.2010 07:15, Changli Gao wrote:
> We'd better guard the size of the nf_ct_ext, as the nf_ct_ext.len is u8.
> If the size is bigger than 255, a warning will be printed.

Why are you checking this in basically every possible spot?
Just checking once during registration (assuming the worst
case of a conntrack using every possible extension) should
be enough.
