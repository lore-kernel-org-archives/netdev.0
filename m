From: jamal <hadi@cyberus.ca>
Subject: Re: [Ipsec-tools-devel] Re: IPSEC: on behavior of acquire
Date: 04 Apr 2005 09:09:19 -0400
Message-ID: <1112620159.1087.486.camel@jzny.localdomain>
References: <1112405303.1096.37.camel@jzny.localdomain>
	 <424E454D.4090402@gmc.lt> <1112477326.1088.321.camel@jzny.localdomain>
	 <424FA946.70809@gmc.lt> <1112538566.1096.391.camel@jzny.localdomain>
	 <425067D9.9050603@gmc.lt> <1112618007.1096.465.camel@jzny.localdomain>
	 <42513A2F.7020504@gmc.lt>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ipsec-tools-devel@lists.sourceforge.net, netdev <netdev@oss.sgi.com>,
        nakam@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Aidas Kasparas <a.kasparas@gmc.lt>
In-Reply-To: <42513A2F.7020504@gmc.lt>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-04-04 at 08:59, Aidas Kasparas wrote:
> jamal wrote:
> > I think i have made a bad case of explaining.
> > Yes, I know where acquires terminate. However this is not about where
> > acquires terminate. It is insufficient to assume that a succesful
> > acquire to user space equates to successful interaction to the KE server
> > which will do an update.
> 
> Why?

The reason the kernel sends an acquire is to update larval SAs it
created. The result is either updating the SA or a rejection for that
matter. Else theres failure in communication.

Anology: If you are trying to send a message from one end system
to another and there are multiple hops between them, then just because
it made it to the first hop does not equate it made it to its final
destination. To make it to the final destination, the confirmation has
to come from the target end.
So if you said the KE was the final destination then kernel to user
space was the first hop.
I am not sure if this is clear as an analogy.
 
cheers,
jamal
