From: jamal <hadi@cyberus.ca>
Subject: Re: _High_ CPU usage while routing (mostly) small UDP packets
Date: 07 Dec 2004 08:04:33 -0500
Message-ID: <1102424673.1093.124.camel@jzny.localdomain>
References: <20041206205305.GA11970@soohrt.org>
	 <20041206134849.498bfc93.davem@davemloft.net>
	 <20041206224107.GA8529@soohrt.org> <41B58A58.8010007@draigBrady.com>
	 <20041207112139.GA3610@soohrt.org> <16821.42080.932184.167780@robur.slu.se>
	 <20041207125001.GA26644@soohrt.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, P@draigBrady.com,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Karsten Desler <kdesler@soohrt.org>
In-Reply-To: <20041207125001.GA26644@soohrt.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-12-07 at 07:50, Karsten Desler wrote:

> Currently I'm having problems capturing packets with tcpdump (lots of
> "packets dropped by kernel") which indicates to me that there's
> genuinely not much (enough) idle time sitting around.
> 

Ah, more hints. So you are not trying to forward - rather just packet
capturing?
Are you using a tcpdump patched with mmaped packet socket?

The 230-240Kpps you are reporting as a capture dont seem as unreasonable
as i thought then. Neither would the CPU use.

cheers,
jamal
