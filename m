From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] remove net/README
Date: Fri, 5 Sep 2003 01:07:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030905010725.5ee10cbf.ak@suse.de>
References: <20030904145204.GA27953@compsoc.man.ac.uk>
	<20030904074520.5dceff3e.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: levon@movementarian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030904074520.5dceff3e.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 4 Sep 2003 07:45:20 -0700
"David S. Miller" <davem@redhat.com> wrote:

> On Thu, 4 Sep 2003 15:52:04 +0100
> John Levon <levon@movementarian.org> wrote:
> 
> > This file seems bitrotted and more up to date info is available in
> > MAINTAINERS in large part.
> 
> For some reason I deleted this file from 2.4.x but I never
> did it for 2.5.x, fixed...

When you're doing janitor type stuff currently I would also suggest
an update of the NET4 version numbers:

Linux NET4.0 for Linux 2.x
->
NET4.1 for Linux 2.6 ?  (not that many changes since 2.4, but still a minor increase would be ok)

NET4: Linux TCP/IP 1.0 for NET4.0  (-> 1.1 would be reasonable for TCP/IP and s/4.0/4.1/)

IPv6 v0.8 for NET4.0               (IPv6 has changed a lot, it would probably deserve an 1.0 now.
                                    also 4.0 -> 4.1) 

Also some other users have similar version strings which could be all updated to NET4.1
(appletalk, IPX, decnet etc.) 

-Andi
