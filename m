From: "David S. Miller" <davem@davemloft.net>
Subject: Re: rcv_wnd = init_cwnd*mss
Date: Wed, 27 Oct 2004 22:21:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027222128.365536e7.davem@davemloft.net>
References: <DB2C167D8FFDEA45B8FC0B1B75E3EE154A3B07@usca1ex-priv1.sanmateo.corp.akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Meda, Prasanna" <pmeda@akamai.com>
In-Reply-To: <DB2C167D8FFDEA45B8FC0B1B75E3EE154A3B07@usca1ex-priv1.sanmateo.corp.akamai.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 27 Oct 2004 22:14:33 -0700
"Meda, Prasanna" <pmeda@akamai.com> wrote:

> 
> What is the reason for checking mss with 1<<rcv_wscale?
> include/net/tcp.h:

Because the advertised window field is 16-bits.  It is
interpreted as "value << rcv_wscale"
