From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH} ARP auto-sizing for 2.4.24 - 2.4.26-pre3
Date: Mon, 15 Mar 2004 23:55:04 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0403152350260.6903-100000@netcore.fi>
References: <20040315134412.314b5e23.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: timg@tpi.com, <anton@samba.org>, <netdev@oss.sgi.com>,
        <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040315134412.314b5e23.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 15 Mar 2004, David S. Miller wrote:
> To be honest, while I'm not against making the tables a little bigger,
> for ARP "WHO THE FUCK CARES" if another 100 cycles or so are burnt on
> a lookup.  What setup do you have where ARP performance is a real issue?
> 
> Your original email was nice in describing the fact that ARP does not
> scale, but you've made no foundation on which to erect a claim that
> scalability for ARP (and thus the added complexity/changes) is even
> necessary.

Consider the similar on large subnets (e.g., used with bridged DSL -- 
a /19 is not uncommon), or with IPv6.

Isn't there a problem when an outside attacker brute-force pings every 
IP address in some order?  The intent here is to overload the router 
to do a lot of ARP/ND requests which result to nothing.

Did I misunderstand or is this also something remedied by this patch?  
At least, this particular feature could be very useful.

FWIW, for IPv6, this specific attack has been described in
http://www.ietf.org/internet-drafts/draft-ietf-send-psreq-04.txt
section 4.3.2.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
