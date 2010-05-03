From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] ppp_generic: pull 2 bytes so that
 PPP_PROTO(skb) is valid
Date: Mon, 03 May 2010 13:27:09 -0700 (PDT)
Message-ID: <20100503.132709.266105694.davem@davemloft.net>
References: <4BDF2FD5.2030509@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org, linux-ppp@vger.kernel.org
To: simon@fire.lp0.eu
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <4BDF2FD5.2030509@simon.arlott.org.uk>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Arlott <simon@fire.lp0.eu>
Date: Mon, 03 May 2010 21:19:33 +0100

> In ppp_input(), PPP_PROTO(skb) may refer to invalid data in the skb.
> 
> If this happens and (proto >= 0xc000 || proto == PPP_CCPFRAG) then
> the packet is passed directly to pppd.
> 
> This occurs frequently when using PPPoE with an interface MTU
> greater than 1500 because the skb is more likely to be non-linear.
> 
> The next 2 bytes need to be pulled in ppp_input(). The pull of 2
> bytes in ppp_receive_frame() has been removed as it is no longer
> required.
> 
> Signed-off-by: Simon Arlott <simon@fire.lp0.eu>

Applied.
