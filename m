From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] packet delay scheduler
Date: 19 Mar 2004 09:52:07 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1079707927.1032.42.camel@jzny.localdomain>
References: <20040316151058.3cc2fa28@dell_ss3.pdx.osdl.net>
	 <20040316174134.2f1da12a.davem@redhat.com>
	 <20040318120451.1c9ee286@dell_ss3.pdx.osdl.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        lartc@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040318120451.1c9ee286@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Stephen,

Good effort but we could do more to capture the essence of nistnet. I am
not familiar with dummynet so cant comment on it. 
For example just with the delaying action nistnet does a lot more
(cutnpaste):
Fixed delays, variable delays with loadable delay probability
distribution (Default distribution is pareto-normal, empirically
parametrized to match observed packet delays), settable mean/variance.

It can also introduce Packet reordering, packet loss, packet
duplication, as well as bandwidth limitation to induce congestion.

You get the point: essentially you have barely scratched the surface.

I think putting all the above in one huge monolithic module is wrong
this being one of the problems i had with nistnet.

The better alternative is to use the tc extension patches i have
because then you could write little modules which do different things
and cascade them. 

Maybe as an example i can rewrite the fixed delayer you wrote as an
action module. The only catch is the patches i have are still in 2.4.x
at the moment. Let me know if you are interested and i could pass you
the patches.

cheers,
jamal
