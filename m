From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND v2] ipv4: Do not cache routing failures due to
 disabled forwarding.
Date: Thu, 30 Oct 2014 19:21:15 -0400 (EDT)
Message-ID: <20141030.192115.918754566952396661.davem@davemloft.net>
References: <20141029.150328.530876391340346443.davem@davemloft.net>
	<1414660193-4177-1-git-send-email-nicolas.cavallari@green-communications.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: nicolas.cavallari@green-communications.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414660193-4177-1-git-send-email-nicolas.cavallari@green-communications.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Cavallari <nicolas.cavallari@green-communications.fr>
Date: Thu, 30 Oct 2014 10:09:53 +0100

> If we cache them, the kernel will reuse them, independently of
> whether forwarding is enabled or not.  Which means that if forwarding is
> disabled on the input interface where the first routing request comes
> from, then that unreachable result will be cached and reused for
> other interfaces, even if forwarding is enabled on them.  The opposite
> is also true.
> 
> This can be verified with two interfaces A and B and an output interface
> C, where B has forwarding enabled, but not A and trying
> ip route get $dst iif A from $src && ip route get $dst iif B from $src
> 
> Signed-off-by: Nicolas Cavallari <nicolas.cavallari@green-communications.fr>
> Reviewed-by: Julian Anastasov <ja@ssi.bg>

Applied and queued up for -stable, thanks.
