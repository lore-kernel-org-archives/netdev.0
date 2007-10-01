From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 1/1][TCP]: break missing at end of switch statement
Date: Mon, 1 Oct 2007 14:39:28 +0100
Message-ID: <200710011439.28676@strip-the-willow>
References: <200710011332.43657@strip-the-willow> <20071001.222059.11266966.yoshfuji@st-paulia.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: YOSHIFUJI Hideaki <yoshfuji@st-paulia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:51031 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751633AbXJANkD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2007 09:40:03 -0400
In-Reply-To: <20071001.222059.11266966.yoshfuji@st-paulia.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting YOSHIFUJI Hideaki:
| 
|  > [TCP]: break missing at end of switch statement
|  > 
|  > Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
|  > ---
|  > --- a/net/ipv4/tcp_input.c
|  > +++ b/net/ipv4/tcp_input.c
|  > @@ -3129,6 +3129,7 @@ static void tcp_reset(struct sock *sk)
|  >  			return;
|  >  		default:
|  >  			sk->sk_err = ECONNRESET;
|  > +			break;
|  >  	}
|  >  
|  >  	if (!sock_flag(sk, SOCK_DEAD))
|  
|  NAK; it is not required at all.
|  
|  --yoshfuji
|  
If it were true what you are saying then the statement 

       `sk->sk_err = ECONNRESET;' 

can go as well since it will always be overridden.
