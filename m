From: jamal <hadi@cyberus.ca>
Subject: Re: Allowing netlink_family to be any integer (was: [PATCH 2.6]
	iptables CLUSTERIP target)
Date: 22 Oct 2004 08:19:54 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098447593.1112.77.camel@jzny.localdomain>
References: <E1CKkWZ-0005x5-00@gondolin.me.apana.org.au>
	 <1098444579.1112.66.camel@jzny.localdomain>
	 <20041022113939.GA812@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
        Harald Welte <laforge@netfilter.org>, lmb@suse.de, ahu@ds9a.nl,
        hch@infradead.org, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041022113939.GA812@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-10-22 at 07:39, Herbert Xu wrote:
> On Fri, Oct 22, 2004 at 07:29:39AM -0400, jamal wrote:
> > 
> > Evgeniy Polyakov(aka mr. Sean Paul) posted code a while back for
> > something that uses netlink that he calls  "kernel Konnector". I think
> 
> That patch puts the ID in each message, right?

Yes, the ID is necessary for "routing" the message. Remember this is for
a messaging subsystem so you cant avoid having something that is in the
packet that is used to find where to go next.
I was suggesting also messaging by name.

> That would mean paying the lookup cost for each message rather than
> once when you create the socket.
> 

Take a look at the patch. See how it can be made better.
Evgeniy, Do you have something new to post?

cheers,
jamal
