From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH 0/3] bonding: 3 fixes for 2.6.24
Date: Wed, 9 Jan 2008 10:27:40 -0500
Message-ID: <20080109152740.GE8728@gospo.usersys.redhat.com>
References: <11997574203125-git-send-email-fubar@us.ibm.com> <Pine.LNX.4.64.0801081949290.1135@bizon.gios.gov.pl> <29560.1199820632@death> <Pine.LNX.4.64.0801090732490.1135@bizon.gios.gov.pl> <17850.1199865514@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krzysztof Oledzki <olel@ans.pl>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48044 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752092AbYAIP3e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 10:29:34 -0500
Content-Disposition: inline
In-Reply-To: <17850.1199865514@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 08, 2008 at 11:58:34PM -0800, Jay Vosburgh wrote:
> Krzysztof Oledzki <olel@ans.pl> wrote:
> 
> >Fine. Just let you know that someone test your patches and everything
> >works, except mentioned problem.
> 
> 	And I appreciate it; I just wanted to make sure our many fans
> following along at home didn't misunderstand.
> 
> 	Could you let me know if the patch below make the lockdep
> warning go away?  This applies on top of the previous three, although it
> should be trivial to do by hand.
> 
> 	I'm still checking to make sure this is safe with regard to
> mutexing the bonding structures, but it would be good to know if it
> eliminates the warning.
> 
> 	-J
> 

Jay,

My initial concern was that a slave device could disappear out from
under us, but it seems like this certainly isn't the case since all
calls to bond_release are protected by rtnl-locks, so I think you are
correct that we are safe.  I'll test this on my setup here and let you
know if I see any problems.

-andy



