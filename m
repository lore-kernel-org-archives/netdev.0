From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] IPV6: missing xfrm_loock() in
 icmpv6_{send,echo_reply}()
Date: Tue, 14 Sep 2004 22:49:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040914224917.033f807e.davem@davemloft.net>
References: <20040915.090424.59114323.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org, miyazawa@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040915.090424.59114323.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Sep 2004 09:04:24 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> net/ipv6/icmp.c was not converted in xfrm_lookup() extraction patch.
> This patch converts it; adding the missing call to xfrm_lookup in
> icmpv6_{send,echo_reply}().
> 
> Signed-off-by: Kazunori Miyazawa <kazunori@miyazawa.org>
> Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

Applied, thanks a lot.
