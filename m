From: Ben Greear <greearb@candelatech.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Mon, 18 Aug 2003 20:21:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F41979C.3070408@candelatech.com>
References: <Pine.LNX.3.96.1030818171100.2101C-100000@gatekeeper.tmr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, Willy Tarreau <willy@w.ods.org>,
   alan@lxorguk.ukuu.org.uk, carlosev@newipnet.com, lamont@scriptkiddie.org,
   bloemsaa@xs4all.nl, marcelo@conectiva.com.br, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Bill Davidsen <davidsen@tmr.com>
In-Reply-To: <Pine.LNX.3.96.1030818171100.2101C-100000@gatekeeper.tmr.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bill Davidsen wrote:

> Okay, I'll show my ignorance and ask... the Documentation for arp_filter
> says source routing must be used. Is there some flag I'm missing, or a way
> to avoid having a rule per address, or is the 8 bit rule number larger in
> 2.6, or ??? Or is having a lot of IPs on one machine not an imaginable
> case?

Last response I got was that one would have to hack the netlink api to get
a bigger index because the design (and rfc, unfortunately) describe the
field as only 8 bits.  I never did hear a response to my comment that this
was inadequate in this age of vlans...

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
