From: jamal <hadi@cyberus.ca>
Subject: Re: netif_rx packet dumping
Date: 03 Mar 2005 16:24:25 -0500
Message-ID: <1109885065.1098.285.camel@jzny.localdomain>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>
	 <20050303125556.6850cfe5.davem@davemloft.net>
	 <1109884688.1090.282.camel@jzny.localdomain>
	 <20050303132143.7eef517c@dxpl.pdx.osdl.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, rhee@eos.ncsu.edu,
        jheffner@psc.edu, Yee-Ting.Li@nuim.ie, baruch@ev-en.org,
        netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050303132143.7eef517c@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-03-03 at 16:21, Stephen Hemminger wrote:

> My plan is to keep netif_max_backlog but bump it up to something bigger
> by default. Maybe even autosize it based on memory available.  But
> get rid of the "dump till empty" behaviour that screws over TCP.

Ok, this does sound more reasonable. Out of curiosity, are packets being
dropped at the socket queue? Why is "dump till empty" behaviour screwing
over TCP.

cheers,
jamal
