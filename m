From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6, mcast: deactivate timers before
 ipv6_mc_destroy_dev()
Date: Tue, 7 Oct 2003 07:41:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031007074152.2b6ae089.davem@redhat.com>
References: <20031005090610.GA23600@wsx.ksp.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jan Oravec <jan.oravec@6com.sk>
In-Reply-To: <20031005090610.GA23600@wsx.ksp.sk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 5 Oct 2003 11:06:10 +0200
Jan Oravec <jan.oravec@6com.sk> wrote:

> the following patch calls ipv6_mc_down(idev) to deactivate timers. If we do
> not deactivate them, the following may happen:

Applied, thanks a lot Jan.
