From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] packet delay scheduler
Date: Fri, 19 Mar 2004 14:21:12 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040319142112.0ad562fe.davem@redhat.com>
References: <20040316151058.3cc2fa28@dell_ss3.pdx.osdl.net>
	<20040316174134.2f1da12a.davem@redhat.com>
	<20040318120451.1c9ee286@dell_ss3.pdx.osdl.net>
	<1079707927.1032.42.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com, lartc@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1079707927.1032.42.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 19 Mar 2004 09:52:07 -0500
jamal <hadi@cyberus.ca> wrote:

> The better alternative is to use the tc extension patches i have
> because then you could write little modules which do different things
> and cascade them. 

I agree that this chaining idea of tc actions is the end-all-be-all
way to do this kind of stuff.

But for now we can put Stephen's delay scheduler in the tree, and I
don't see any real problem with that until your tc action changes
are ready for integration.
