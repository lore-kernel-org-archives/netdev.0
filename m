From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]: Fix skb leak in igmpv3_newpack
Date: Sat, 29 May 2004 12:39:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040529123938.27d913f3.davem@redhat.com>
References: <40B71A62.6050008@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <40B71A62.6050008@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 28 May 2004 12:54:26 +0200
Patrick McHardy <kaber@trash.net> wrote:

> This patch fixes an skb-leak in igmpv3_newpack. skb isn't
> freed when rt->rt_src == 0. Patch applies to 2.4 and 2.6.

Applied to both trees, thanks.
