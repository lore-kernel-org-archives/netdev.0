From: "David S. Miller" <davem@redhat.com>
Subject: Re: Fw: [PATCH][2.6] propogate rx errors from raw_rcv_skb
Date: Mon, 21 Jul 2003 05:25:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030721052552.7536fccc.davem@redhat.com>
References: <20030716195345.21b9b9fc.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org, zwane@arm.linux.org.uk
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030716195345.21b9b9fc.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Jul 2003 19:53:45 -0700
"David S. Miller" <davem@redhat.com> wrote:

> 	This looks somewhat sane, ipv6 doesn't seem to need it as it 
> always returns 0

Nothing that calls raw_rcv() checks the return value,
so what's the point?
