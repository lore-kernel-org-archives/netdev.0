From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 1/1][TCP]: break missing at end of switch statement
Date: Mon, 1 Oct 2007 14:02:10 +0100
Message-ID: <200710011402.10377@strip-the-willow>
References: <200710011332.43657@strip-the-willow> <20071001123430.GZ8181@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Al Viro <viro@ftp.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:49574 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751328AbXJANCG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2007 09:02:06 -0400
In-Reply-To: <20071001123430.GZ8181@ftp.linux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Al Viro:
|  On Mon, Oct 01, 2007 at 01:32:43PM +0100, Gerrit Renker wrote:
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
|  
|  Huh?  Why on the Earth would that be a problem?
|  
|  
Sorry what is your question?
