From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: 2.5.70-bk+ broken networking
Date: Wed, 4 Jun 2003 16:25:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030604162528.637ae1ff.shemminger@osdl.org>
References: <20030604161437.2b4d3a79.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, davem@redhat.com, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030604161437.2b4d3a79.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 4 Jun 2003 16:14:37 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Test machine running 2.5.70-bk latest can't boot because eth2 won't
> come up.  The same machine and configuration successfully brings up
> all the devices and runs on 2.5.70.
> 
> Starting ip6tables:  [  OK  ]
> Starting iptables:  [  OK  ]
> Setting network parameters:  [  OK  ]
> Bringing up loopback interface:  [  OK  ]
> Bringing up interface eth0:  [  OK  ]
> Bringing up interface eth1:  [  OK  ]
> Bringing up interface eth2:  sender address length == 0
> e1000 device does not seem to be present, delaying eth2 initialization.
> [FAILED]

One more piece of info:
eth0 and eth1 are e100
eth2 is e1000
