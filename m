From: Andi Kleen <ak@suse.de>
Subject: Re: 3c59x (was Route cache performance under stress)
Date: Tue, 10 Jun 2003 18:49:49 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030610164949.GB13246@wotan.suse.de>
References: <20030610.085600.71109220.davem@redhat.com> <Pine.LNX.4.44.0306101815550.26879-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, sim@netnation.com,
	ralph+d@istop.com, hadi@shell.cyberus.ca, xerox@foonet.net,
	fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0306101815550.26879-100000@kenzo.iwr.uni-heidelberg.de>
List-Id: netdev.vger.kernel.org

> 
> And another important question: how much improvement can be gained from
> the driver ? Folks that do parallel computation over TCP over Ethernet

You can play some tricks with the driver to make eth_type_trans disappear
from the profiles. This usually helps a lot because it avoids one
full "fetch from cache cold memory" roundtrip per packet, which is slow on
any CPU.

-Andi

