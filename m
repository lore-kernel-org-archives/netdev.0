From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] proportional share accept()
Date: Wed, 25 Feb 2004 12:03:50 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040225120350.499bc573@dell_ss3.pdx.osdl.net>
References: <20040225092116.2081ddfb@dell_ss3.pdx.osdl.net>
	<Pine.WNT.4.44.0402251101300.1572-100000@w-vkashyap95.des.sequent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Vivek Kashyap <kashyapv@us.ibm.com>
In-Reply-To: <Pine.WNT.4.44.0402251101300.1572-100000@w-vkashyap95.des.sequent.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 25 Feb 2004 11:04:13 -0800 (Pacific Standard Time)
Vivek Kashyap <kashyapv@us.ibm.com> wrote:

> Stephen,
> 
> I've not understood your suggestion. How would you implement the solution?

I assume the goal is to provide some high level of resource control over network utilization
in a system. The accept proposal is part of more general problem of how to virtualize
the network infrastructure and services to provide different QoS based on a set of
parameters.

Your assumption that server application is blind to all this. But the kind of applications
that would need this resource control are already pretty smart (databases and web servers).
So wouldn't you want the application to be involved.  Imagine a database;  wouldn't you want
connections that come in with high priority to be scheduled in the database with high priority?

Your solution seems like having an express line to get into Disneyland, but still
ending up waiting for all the rides...

It just seems to add more complexity, complexity isn't always bad; just something
that should be avoided if possible.
