From: jamal <hadi@cyberus.ca>
Subject: Re: Allowing netlink_family to be any integer (was: [PATCH 2.6]
	iptables CLUSTERIP target)
Date: 22 Oct 2004 07:29:39 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098444579.1112.66.camel@jzny.localdomain>
References: <E1CKkWZ-0005x5-00@gondolin.me.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@netfilter.org>, lmb@suse.de, ahu@ds9a.nl,
        hch@infradead.org, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>,
        Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <E1CKkWZ-0005x5-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Evgeniy Polyakov(aka mr. Sean Paul) posted code a while back for
something that uses netlink that he calls  "kernel Konnector". I think
thats a good idea which will ease the use of those limited numbers. It
also has potential for generic kernel-kernel as well as kernel-userspace
messaging subsystem.
I printed the code, got a large cup of brazillian-derived cappucino but
alas got preempted before finishing the rewiew. Maybe you could work
with him Herbert?
I still plan to continue looking at it.

This does not exclude the use of the netlink numbers, but should ease
them.

cheers,
jamal

On Thu, 2004-10-21 at 17:31, Herbert Xu wrote:
> Harald Welte <laforge@netfilter.org> wrote:
> >
> > For supporting two primitive operation, adding a new netlink address
> > family also isn't worthwhile, especially since we're short of netlink
> > families.
> 
> That's something I'm looking into as well.  The current strategy of
> either creating a new family or tacking random things into RTNETLINK
> is simply not going to scale.
> 
> Initially I considered an interface where kernel users can register
> themselves using a string as the key.  But I soon realised that we
> could simply allow the netlink_family field to be an arbitrary integer
> that is used as a key to a hash table.
> 
> The CPU cost of the hash table isn't too bad since you'll only be
> looking it up when the socket is created.
> 
> Comments anyone?
