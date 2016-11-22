From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] flow_dissect: call init_default_flow_dissectors()
 earlier
Date: Tue, 22 Nov 2016 14:44:44 -0500 (EST)
Message-ID: <20161122.144444.2261159964230408258.davem@davemloft.net>
References: <1479838123.681.173.camel@intel.com>
        <20161122182258.GF19939@tuebingen.mpg.de>
        <1479842250.8455.452.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maan@tuebingen.mpg.de, jiri@resnulli.us,
        alexander.h.duyck@intel.com, edumazet@google.com,
        linux-kernel@vger.kernel.org, ast@kernel.org, willemb@google.com,
        gregkh@linuxfoundation.org, jslaby@suse.cz, yibyang@cisco.com,
        netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479842250.8455.452.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 22 Nov 2016 11:17:30 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Andre Noll reported panics after my recent fix (commit 34fad54c2537
> "net: __skb_flow_dissect() must cap its return value")
> 
> After some more headaches, Alexander root caused the problem to
> init_default_flow_dissectors() being called too late, in case
> a network driver like IGB is not a module and receives DHCP message
> very early.
> 
> Fix is to call init_default_flow_dissectors() much earlier,
> as it is a core infrastructure and does not depend on another
> kernel service.
> 
> Fixes: 06635a35d13d4 ("flow_dissect: use programable dissector in skb_flow_dissect and friends")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andre Noll <maan@tuebingen.mpg.de>
> Diagnosed-by: Alexander Duyck <alexander.h.duyck@intel.com>

Applied and queued up for -stable, I'll try to fast-track this.
