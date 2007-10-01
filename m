From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [PATCH 1/1][TCP]: break missing at end of switch statement
Date: Mon, 1 Oct 2007 14:17:58 +0100
Message-ID: <20071001131758.GA8181@ftp.linux.org.uk>
References: <200710011332.43657@strip-the-willow> <20071001123430.GZ8181@ftp.linux.org.uk> <200710011402.10377@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:47945 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757048AbXJANR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 09:17:59 -0400
Content-Disposition: inline
In-Reply-To: <200710011402.10377@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 01, 2007 at 02:02:10PM +0100, Gerrit Renker wrote:
> Quoting Al Viro:
> |  On Mon, Oct 01, 2007 at 01:32:43PM +0100, Gerrit Renker wrote:
> |  > [TCP]: break missing at end of switch statement
> |  > 
> |  > Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> |  > ---
> |  > --- a/net/ipv4/tcp_input.c
> |  > +++ b/net/ipv4/tcp_input.c
> |  > @@ -3129,6 +3129,7 @@ static void tcp_reset(struct sock *sk)
> |  >  			return;
> |  >  		default:
> |  >  			sk->sk_err = ECONNRESET;
> |  > +			break;
> |  >  	}
> |  
> |  Huh?  Why on the Earth would that be a problem?
> |  
> |  
> Sorry what is your question?

Why the hell is $Subject a problem that warrants any patches whatsoever?
