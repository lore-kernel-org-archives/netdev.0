From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Problem with recvmsg() and IPV6_PKTINFO
Date: Tue, 15 Feb 2005 15:21:14 -0800
Message-ID: <20050215152114.7ac33dfe.davem@davemloft.net>
References: <20050211092107.GB12377@storhaugen.uninett.no>
	<20050211.183859.77973026.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: Stig.Venaas@uninett.no, netdev@oss.sgi.com
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20050211.183859.77973026.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 11 Feb 2005 18:38:59 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> In article <20050211092107.GB12377@storhaugen.uninett.no> (at Fri, 11 Feb 2005 10:21:07 +0100), Stig Venaas <Stig.Venaas@uninett.no> says:
> 
> > I've found that on Linux (checked 2.4, 2.6 and USAGI cvs) this only
> > happens if msg_name in the msghdr structure is set. In kernel's
> > udpv6_recvmsg() you can see that datagram_recv_ctl() is only called if
> > msg->msg_name is set.
> 
> Please try this. Thanks.
> 
> Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

Applied, thank you very much.
