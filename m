From: jamal <hadi@cyberus.ca>
Subject: Re: [NET]: Avoid useless iterating in netlink dump functions
Date: Fri, 06 May 2005 17:17:02 -0400
Message-ID: <1115414222.13922.41.camel@localhost.localdomain>
References: <427B8FC3.4000305@trash.net>
	 <1115413473.13922.38.camel@localhost.localdomain>
	 <427BDDD4.1000808@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <427BDDD4.1000808@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-06-05 at 23:12 +0200, Patrick McHardy wrote:
> jamal wrote:
> > Looks good - you may also wanna treat tcf_dump_walker() and
> > xfrm_dump_sa() the same way then. 
> > 
> 
> action dumping is on my list for more treatment than this :)

Well, that does sound scary ;-> What do you have in mind.
Recall, there are two paths to dumping actions - unlike any other thing
in the kernel.

> xfrm_dump_sa()/xfrm_state_walk() could be changed to skip
> smarter, but that is a different kind of change.
> 

I noticed the policy too is of the the same way. Those are actually a
little more trickier than they appear.

cheers,
jamal
