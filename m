From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: suggestion for routing code improvement
Date: Wed, 10 Apr 2002 16:56:27 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <3CB4A6FB.F9146FDB@nortelnetworks.com>
References: <3CB47B90.B4CF1FAD@nortelnetworks.com> <15540.40277.772027.111512@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
> 
> Chris Friesen writes:
>  > So, what do you guys think?  Is this a reasonable thing to do?  I think that it
>  > makes the system nicely symmetrical, as opposed to the asymmetrical handling of
>  > current kernels.
> 
>  Hello!
> 
>  Why not leave the routing policy job to a routing daemon?

Because I've got static routes, and I know exactly what they are.

>  This Linux box has 110441 bgp routes. Internet routing is very much
>  like a living organism. Routes comes and goes.

The box(es) which inspired this sit on a private network, and once they are
brought into service, the routes never change.  However, there is a command from
our gui to manually drop and raise the ethernet link (just in case something
goes wrong and can't be handled automatically) and it would simplify our code
greatly if the routes that are automatically deleted would be automatically put
back.

>  If the interface comes back the router daemon recalcs again and installs
>  appropriate routes for this moment which may very well be different
>  compared to before "link down".

In this case, my software *is* essentially the routing daemon, and I want it to
be simpler to maintain.

I think the concept is simple: I added some routes, and I think they should stay
there until I remove them or the machine reboots.  Doesn't this seem like a
logical behaviour?

Chris

-- 
Chris Friesen                    | MailStop: 043/33/F10  
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com
