From: Patrick McHardy <kaber@trash.net>
Subject: Re: patch: annoying u32 double listing
Date: Sun, 06 Feb 2005 22:47:22 +0100
Message-ID: <4206906A.2060501@trash.net>
References: <1107719343.1055.22.camel@jzny.localdomain> <20050206212928.GV31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050206212928.GV31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

>Another
>quite anoying detail is the fact that cbq uses the same handle for
>both the root qdisc and root class which makes it impossible to uniquely
>assign filters attached to it, i.e. listing filters based on
>parent == XX: && dev == %DEV will result in the filters being listed
>for both the qdisc and the class.
>
CBQ and HFSC only support filters attached to classes for exactly this
reason :) Shouldn't make any difference from a users perspective.

Regards
Patrick
