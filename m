From: jamal <hadi@cyberus.ca>
Subject: Re: patch: annoying u32 double listing
Date: 06 Feb 2005 16:42:13 -0500
Message-ID: <1107726133.1055.34.camel@jzny.localdomain>
References: <1107719343.1055.22.camel@jzny.localdomain>
	 <20050206212928.GV31837@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050206212928.GV31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-02-06 at 16:29, Thomas Graf wrote:

> assign filters attached to it, i.e. listing filters based on
> parent == XX: && dev == %DEV will result in the filters being listed
> for both the qdisc and the class. I haven't found a fix that wouldn't
> break many scripts so if you have a good idea, go ahead. ;->

I cant say ive run into this one - mostly i attach filters to root.
Example script?

BTW, cycles allow me to work on the eaction stuff today. So far
ive come to the conclusion that whats really needed to simplify
writting some actions is to just provide generic methods they
can use without them necessarily knowing details. I hope to test
later on, maybe write a simple action and its user apce piece, and post
patch.

cheers,
jamal
