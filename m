From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: SAD sometimes has double SAs.
Date: Mon, 26 Mar 2007 14:48:43 -0700 (PDT)
Message-ID: <20070326.144843.72708308.davem@davemloft.net>
References: <200703232258.l2NMwKqH016994@faith.austin.ibm.com>
	<1174944899.17953.20.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: latten@austin.ibm.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, jmorris@namei.org, paul.moore@hp.com,
	vyekkirala@trustedcs.com
To: eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37133
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932886AbXCZVsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2007 17:48:45 -0400
In-Reply-To: <1174944899.17953.20.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Paris <eparis@redhat.com>
Date: Mon, 26 Mar 2007 17:34:59 -0400

> I'm not at all able to speak on the correctness or validity of the
> solution,

Neither am I yet :)

> but shouldn't the ipv6 case be a && not an || like the ipv4
> case?  Isn't this going to match all sorts of things?  Did you test this
> patch on ipv6 and see it to solve your problem?
> 
> I'm also not enjoying the formatting in the ipv6 part where the first
> time you have the cast on the same time as the object but not the second
> part where x->props.saddr.a6 is on its own little line.

Also, I want to understand what is going to tear down these
"other direction" fake entries later on?  I think I can review
this patch better if I understand that.

As it stands, this looks to me like a workaround for an improperly
implemented IPSEC daemon.  Joy states it as saying that the current
code requires the keying daemon to manage it's SAs, and I wonder
whether any other implementation is even valid.

There is a limit to the amount to which we can workaround racoon's
design issues. :-)
