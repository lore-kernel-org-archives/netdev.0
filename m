From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6 MIB:ipv6DefaultRouterTable
Date: Thu, 15 Jan 2004 11:38:40 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040115113840.4b7eb5d8.davem@redhat.com>
References: <OF6C177E72.62FA8BF9-ON87256E1C.006A8953@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, mashirle@us.ibm.com, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Shirley Ma <xma@us.ibm.com>
In-Reply-To: <OF6C177E72.62FA8BF9-ON87256E1C.006A8953@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 15 Jan 2004 11:30:25 -0800
Shirley Ma <xma@us.ibm.com> wrote:

> I don't see any application uses these values for now, so I change them.
> It's good for kernel to provide the real MIBs information. If later on,
> some applications start to use these values, they can get the correct
> numbers without converting. Unless you can give me an broken example. :-)

Format and layout of procfs files have to stay as they are, this is just the
nature of the game.

We can create new files to present information in new ways and formats,
but I totally prefer using netlink based information gathering over making
new procfs files.
