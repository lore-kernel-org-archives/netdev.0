From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: RFC: per-socket statistics on received/dropped packets
Date: Fri, 07 Jun 2002 11:34:35 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <adqk59$d9$2@main.gmane.org>
References: <3CFFB9F8.54455B6E@nortelnetworks.com> <20020606.202108.52904668.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
List-Id: netdev.vger.kernel.org

"David S. Miller" wrote:
> 
> Your idea is totally useless for non-datagram sockets.
> Only datagram sockets use the interfaces where you bump
> the counters.
> 
> I don't like the patch, nor the idea behind it, at all.

Thanks for the feedback.

I buy the point about it only making sense for datagram sockets in its current
form.  Thus it would maybe make more sense to use udp_ioctl() rather than in the
generic socket ioctl.

However, what do you have against the basic idea of a program knowing how many
packets have 
been dropped on its sockets?  I added the feature to try and figure out where
packets were being dropped in an app I am developing, and so far its been very
useful.

More generally, is there a generic place that I could tie into for the counter
increment that would work for all sockets?  While tcp would automatically handle
the dropped packets, it might be useful to know how many there were.

Thanks,

Chris

-- 
Chris Friesen                    | MailStop: 043/33/F10  
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com
