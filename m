From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: Thu, 26 Jun 2003 19:18:20 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030626190407.S87648@shell.cyberus.ca>
References: <20030625.143334.85380461.davem@redhat.com>
 <20030626035824.D68B62C147@lists.samba.org> <20030625.205941.41631020.davem@redhat.com>
 <16122.53298.150512.793074@h006008986325.ne.client2.attbi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, rusty@rustcorp.com.au,
   paulus@samba.org, netdev@oss.sgi.com, fcusack@samba.org
Return-path: <netdev-bounce@oss.sgi.com>
To: James Carlson <carlson@workingcode.com>
In-Reply-To: <16122.53298.150512.793074@h006008986325.ne.client2.attbi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Thu, 26 Jun 2003, James Carlson wrote:

> David S. Miller writes:
> If so, then that needs to be taken up with the manufacturer.  That's a
> rather severe design flaw that will prevent such a card from ever
> being used for anything other than IP -- many other protocols *ASSUME*
> that packets on a single wire cannot be reordered, including SNA, PPP
> (!), and link aggregation, among others.
>

So what about packet being loss? Wouldnt that ensure reordering?
And there is no such thing as a lossless wire.

cheers,
jamal

PS:- Paulus i wasnt preaching getting rid of ppp/pppoe although its
a nice thouhgt. More fix linux pppd and pppoe ;->
