From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Device naming for wireless NICs...
Date: Thu, 11 Mar 2004 13:25:15 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4050AF0B.7040901@pobox.com>
References: <Pine.LNX.4.44.0403111146240.21414-100000@lacrosse.corp.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Ketrenos <jketreno@linux.co.intel.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matthew Galgoci <mgalgoci@redhat.com>
In-Reply-To: <Pine.LNX.4.44.0403111146240.21414-100000@lacrosse.corp.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Matthew Galgoci wrote:
> Going forward it might be worth while to standardize all wireless interface names, just
> to show at a glance that an interface is 802.11x, and also to differentiate the fact that
> eventually 802.11 will be its own network stack.

I definitely want to standardize on something like wlan%d.  We should 
get that for free when a generic 802.11 stack is in place, which implies 
that there will be a common wireless helper as a peer to ether_setup() 
in the current tree.

	Jeff
