From: Andreas Jellinghaus <aj@dungeon.inka.de>
Subject: Re: ipsec 2.5.70 trouble
Date: 30 May 2003 01:39:43 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1054251582.2598.57.camel@simulacron>
References: <1054235155.596.9.camel@simulacron>
	 <20030529.141410.85405194.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030529.141410.85405194.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2003-05-29 at 23:14, David S. Miller wrote:
> After we do the transformation, we stick it back into
> the nework stack input to prevent stack exhaustion.
> 
> And yes it is on purpose and not changing.

ok. I can't "GET http://www.microsoft.com/" (and lots of other
websites). The setup is laptop -> wlan+ipsec (esp, tunnel mode) ->
firewall+nat -> pppoe -> internet.

01:34:25.500786 212.202.202.151.33369 > 207.46.249.190.80: S
750265125:750265125 (0) win 5840 <mss 1460,sackOK,timestamp 17523110
0,nop,wscale 0> (DF)
01:34:25.661897 207.46.249.190.80 > 212.202.202.151.33369: S
2015313287:2015313287(0) ack 750265126 win 16384 <mss 1460,nop,wscale
0,nop,nop,timestamp 0 0,nop,nop,sackOK>
01:34:25.665581 212.202.202.151.33369 > 207.46.249.190.80: . ack 1 win
5840 <nop,nop,timestamp 17523275 0> (DF)
01:34:25.676682 212.202.202.151.33369 > 207.46.249.190.80: P 1:93(92)
ack 1 win 5840 <nop,nop,timestamp 17523286 0> (DF)
01:34:26.513105 212.202.202.151.33369 > 207.46.249.190.80: P 1:93(92)
ack 1 win 5840 <nop,nop,timestamp 17524123 0> (DF)
01:34:26.673758 207.46.249.190.80 > 212.202.202.151.33369: . ack 93 win
65443 <nop,nop,timestamp 3697004 17524123> (DF)
01:34:28.437372 212.202.202.151.33369 > 207.46.249.190.80: F 93:93(0)
ack 1 win 5840 <nop,nop,timestamp 17526047 0> (DF)
01:34:28.597316 207.46.249.190.80 > 212.202.202.151.33369: . ack 94 win
65443 <nop,nop,timestamp 3697024 17526047> (DF)

Can I do anything about this?

Thanks, Andreas
