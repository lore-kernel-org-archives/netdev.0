From: todd-lkml@osogrande.com
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Mon, 16 Sep 2002 15:32:56 -0600 (MDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0209161528140.13850-100000@gp.staff.osogrande.com>
References: <20020916.125211.82482173.davem@redhat.com>
Reply-To: linux-kernel@vger.kernel.org
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
   "todd-lkml@osogrande.com" <todd-lkml@osogrande.com>,
   "hadi@cyberus.ca" <hadi@cyberus.ca>,
   "tcw@tempest.prismnet.com" <tcw@tempest.prismnet.com>,
   "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
   "pfeather@cs.unm.edu" <pfeather@cs.unm.edu>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20020916.125211.82482173.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

folx,

perhaps i was insufficiently clear.

On Mon, 16 Sep 2002, David S. Miller wrote:

>    are there any standards in progress to support this.
> 
> Your question makes no sense, it is a hardware optimization
> of an existing standard.  The chip merely is told what flows
> exist and it concatenates TCP data from consequetive packets
> for that flow if they arrive in sequence.

hardware optimizations can be standardized.  in fact, when they are, it is 
substantially easier to implement to them.

my assumption (perhaps incorrect) is that some core set of functionality 
is necessary for a card to support zero-copy receives (in particular, the 
ability to register cookies of expected data flows and the memory location 
to which they are to be sent).  what 'existing standard' is this 
kernel<->api a standardization of?

>    who is working on this architecture for receives?
> 
> Once cards with the feature exist, probably Alexey and myself
> will work on it.
> 
> Basically, who ever isn't busy with something else once the technology
> appears.

so if we wrote and distributed firmware for alteon acenics that supported
this today, you would be willing to incorporate the new system calls into
the networking code (along with the new firmware for the card, provided we
could talk jes into accepting the changes, assuming he's still the 
maintainer of the driver)?  that's great.

>    
>    is there a beginning implementation yet of zerocopy receives
> 
> No.


thanks for your feedback.

t.


-- 
todd underwood, vp & cto
oso grande technologies, inc.
todd@osogrande.com

"Those who give up essential liberties for temporary safety deserve
neither liberty nor safety." - Benjamin Franklin
