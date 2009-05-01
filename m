From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] bonding: add mark mode
Date: Fri, 1 May 2009 16:09:40 -0400
Message-ID: <20090501200940.GB5840@hmsreliant.think-freely.org>
References: <20090501173916.GA6608@gospo.rdu.redhat.com> <20090501193403.GA5840@hmsreliant.think-freely.org> <501.1241207536@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55191 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765315AbZEAUJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 16:09:49 -0400
Content-Disposition: inline
In-Reply-To: <501.1241207536@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> 	If I'm not misunderstanding the purpose of the mode, I think
> it's etherchannel compatible (meaning that the switch has to be
> configured), so I'm not sure why there would ever be a need to flood
> packets to all ports.
> 
It entirely possible that there may be no need to flood frames, I was just
asking the question.  And while it is possible that this might be etherchannel
compatible (in fact I agree, it does look compatible), I can see uses for it
beyond that (active-backup with traffic-class load balancing for example).

> 	I think this would be generally be better a special hash policy,
> in which case both the etherchannel (balance-xor) and 802.3ad modes
> could take advantage of it.  I'd hazard to guess that Andy thought about
> that, too, so what was the impediment?
> 

I honestly don't know, although I will say that making a special hash mode for
balance-xor seems a bit odd, since the implication there would be that output
port was no longer chosen by an xor operation.
Neil

