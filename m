From: Frank Cusack <fcusack@fcusack.com>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: Sat, 28 Jun 2003 15:51:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030628155119.A15491@google.com>
References: <20030625.143334.85380461.davem@redhat.com> <20030626035824.D68B62C147@lists.samba.org> <20030625.205941.41631020.davem@redhat.com> <16122.53298.150512.793074@h006008986325.ne.client2.attbi.com> <20030626190407.S87648@shell.cyberus.ca> <16124.11495.374998.153330@h006008986325.ne.client2.attbi.com> <20030627213846.V90398@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Carlson <carlson@workingcode.com>,
   "David S. Miller" <davem@redhat.com>, rusty@rustcorp.com.au,
   paulus@samba.org, netdev@oss.sgi.com, fcusack@samba.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamal Hadi <hadi@shell.cyberus.ca>
Content-Disposition: inline
In-Reply-To: <20030627213846.V90398@shell.cyberus.ca>; from hadi@shell.cyberus.ca on Fri, Jun 27, 2003 at 10:21:21PM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jun 27, 2003 at 10:21:21PM -0400, Jamal Hadi wrote:
> On Fri, 27 Jun 2003, James Carlson wrote:
> >
> > Loss preserves ordering.  To get misordering, you have to
> > intentionally hold onto a message and reinsert it later.  What I've
> 
> And thats what i was implying.
> In your above example:
> 
> 1 2 4 5 6
> If the entity above the wire cared about packet 3 there will be a
> retransmit. so it becomes:
> 
> 1 2 4 5 6 3

Higher layer entities doing retransmits is not reordering.  To the lower
layer, it's just the next message.

/fc
