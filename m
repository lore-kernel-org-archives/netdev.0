From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.5.70] Add release_netdev -- hook for sysfs/net device cleanup
Date: Mon, 9 Jun 2003 13:14:46 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030609171446.GA15239@gtf.org>
References: <3EE4045D.4040002@pobox.com> <20030608.225309.39172149.davem@redhat.com> <3EE4BF39.2020503@pobox.com> <20030609.100948.84378474.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030609.100948.84378474.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jun 09, 2003 at 10:09:48AM -0700, David S. Miller wrote:
>    From: Jeff Garzik <jgarzik@pobox.com>
>    Date: Mon, 09 Jun 2003 13:09:13 -0400
> 
>    David S. Miller wrote:
>    > That's your plan, but did you do any of this yet?  It'll keep
>    > going deeper and deeper into bitkeeper history the longer that
>    > you wait :-)
>    
>    Yes, I have been following my plan.  You will see when Marcelo opens 
>    2.4.22-pre1 that I have been committing these to my net-drivers-2.4 queue.
> 
> Awesome.
> 
> Now why was I asking this to begin with?  You wanted to do something,
> what was that? :-)

I wanted to wait on the s/kfree/release_netdev/ patch until the other
stuff is done.  Said patch can be applied anytime, and doing it in this
order reduces 2.4 backport merge pain.  :)

	Jeff
