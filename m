From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: Marvell 88E609x switch?
Date: Sat, 07 Mar 2009 16:53:45 +0100
Message-ID: <1236441225.14145.7.camel@localhost.localdomain>
References: <20090227145746.GD17040@xi.wantstofly.org>
	 <49A801E6.1040502@mlbassoc.com> <20090227151441.GE17040@xi.wantstofly.org>
	 <49A80606.1040508@mlbassoc.com> <20090227152721.GG17040@xi.wantstofly.org>
	 <49A806C5.1010200@mlbassoc.com> <20090227153102.GH17040@xi.wantstofly.org>
	 <49A80A75.8000101@mlbassoc.com> <20090227155224.GK17040@xi.wantstofly.org>
	 <Pine.LNX.4.64.0902272211260.19905@ask.diku.dk>
	 <20090227222802.GZ17040@xi.wantstofly.org>
	 <1235991382.30736.62.camel@localhost.localdomain>
	 <1235991937.30736.65.camel@localhost.localdomain>
	 <49ABF7DF.8060302@mlbassoc.com> <49ABF9A9.2040608@mlbassoc.com>
	 <Pine.LNX.4.64.0903022237580.1863@ask.diku.dk>
	 <49AC5E6F.3010204@mlbassoc.com>
	 <1236070372.30736.87.camel@localhost.localdomain>
	 <49AD1C81.1020106@mlbassoc.com>
	 <1236083560.30736.114.camel@localhost.localdomain>
	 <49AD2FE1.60305@mlbassoc.com> <49AD30F7.4080006@mlbassoc.com>
	 <49ADA697.3050400@mlbassoc.com>  <49B145FF.5060208@mlbassoc.com>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	netdev <netdev@vger.kernel.org>
To: Gary Thomas <gary@mlbassoc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:44734 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752360AbZCGPxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2009 10:53:49 -0500
In-Reply-To: <49B145FF.5060208@mlbassoc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-03-06 at 08:49 -0700, Gary Thomas wrote:
> After much experimentation, I finally found out what was
> wrong.  Basically, the trunk masks have 8 bits on the 6131,
> but 11 bits on the 609x and this wasn't being handled.  Once
> the trunk masks were reset by the init code, there was no
> path to the CPU port from the LAN ports :-(  The attached
> patch is what I've ended up with.  It works, at least for
> a single switch.

Thats great! ... finally you discovered the difference :-)

Once you are ready with a more final patch, I'll be happy to review it
(and fixup any whitespace compliance stuff... which the attached patch
does not comply to ;-))

> Next, I need to get it to work with multiple switches (separate
> ethernet controllers, same/shared MII bus), as well as a cascaded
> switch.

Okay, I'll be happy to review any patches, but I don't have any
experience with a multiple switch chip setup...

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer
