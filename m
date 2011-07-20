From: Julia Lawall <julia@diku.dk>
Subject: Re: [patch] skbuff: use kfree_skb() instead of kfree()
Date: Wed, 20 Jul 2011 10:37:11 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1107201035270.24382@ask.diku.dk>
References: <20110720072343.GF6445@shale.localdomain>
 <20110720072549.GG6445@shale.localdomain>  <1311147723.3113.116.camel@edumazet-laptop>
  <20110720080109.GH6445@shale.localdomain> <1311150084.2338.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-511516320-1775040443-1311151031=:24382"
Cc: Dan Carpenter <error27@gmail.com>, Shirley Ma <xma@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:40240 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750745Ab1GTIiE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 04:38:04 -0400
In-Reply-To: <1311150084.2338.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---511516320-1775040443-1311151031=:24382
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 20 Jul 2011, Eric Dumazet wrote:

> Le mercredi 20 juillet 2011 à 11:01 +0300, Dan Carpenter a écrit :
> > On Wed, Jul 20, 2011 at 09:42:03AM +0200, Eric Dumazet wrote:
> > > Le mercredi 20 juillet 2011 à 10:25 +0300, Dan Carpenter a écrit :
> > > > Crap.  Sorry, I shouldn't have sent that.  We shouldn't return the
> > > > freed "n" here.  I'll send a v2 shortly.
> > > 
> > > Also, dont forget to say its a patch for net-next-2.6
> > 
> > If you're using linux-next, is there a way to tell which tree a
> > patch came from?  Obviously in this case it's core networking, but
> > in other cases how does that work?
> 
> In this particular case, David will know for sure since patch is very
> recent, but I wanted to make a general advice.
> 
> Keep in mind David has to review dozens of patches _per_ day, so netdev
> related patches need some extra cooperation from submitters to help the
> maintainer.
> 
> This extra cooperation means to test the patch on either net-next-2.6 or
> net-2.6 tree ;)

Maybe there is some way to integrate such a suggestion in get_maintainers 
or checkpatch?  Otherwise, those who work on the code in a more breadth 
first way don't have much chance of knowing or remembering this advice.

julia
---511516320-1775040443-1311151031=:24382--
