From: Willy Tarreau <willy@w.ods.org>
Subject: Re: Problem with 2.4.24 e1000 and keepalived
Date: Thu, 8 Jan 2004 09:46:05 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040108084605.GA9050@alpha.home.local>
References: <20040107200556.0d553c40.skraw@ithnet.com> <20040107210255.GA545@alpha.home.local> <3FFCC430.4060804@candelatech.com> <20040108052000.GA8829@alpha.home.local> <3FFD0FAE.8050705@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willy Tarreau <willy@w.ods.org>,
        Stephan von Krawczynski <skraw@ithnet.com>,
        linux-kernel <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com,
        linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <3FFD0FAE.8050705@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jan 08, 2004 at 12:07:10AM -0800, Ben Greear wrote:
 
> No, I meant what I said:  You have to tell many drivers to bring the 
> interface
> up before they will attempt (or at least report) link negotiation.
> You do NOT have to give it an IP address or add any routes to it.

ah, OK. No, anyway, it is just a matter of wrongly detecting link state
after the link has been plugged while the interface was already UP, no
matter if an IP was set or not.

> But, I don't know about your particular program, I just suspect it
> is related to detecting link state.  I think tg3 detects link when
> the interface is not UP, if you have some tg3 nics maybe you could
> try with them?

As far as I have tested, tg3 are fine WRT this.

Willy
