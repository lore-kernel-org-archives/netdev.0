From: Stephan von Krawczynski <skraw@ithnet.com>
Subject: Re: Problem with 2.4.24 e1000 and keepalived
Date: Thu, 8 Jan 2004 09:14:41 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040108091441.3ff81b53.skraw@ithnet.com>
References: <20040107200556.0d553c40.skraw@ithnet.com>
	<20040107210255.GA545@alpha.home.local>
	<3FFCC430.4060804@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: willy@w.ods.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3FFCC430.4060804@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 07 Jan 2004 18:45:04 -0800
Ben Greear <greearb@candelatech.com> wrote:

> Willy Tarreau wrote:
> > Hi Stephan,
> > [...]
> > What I noticed is that if you load the driver while the cable is unplugged,
> > and then plug it, the MII status says the link is still down.
> > Unfortunately, the only e100 I have access to are in prod at a customer's
> > and I really cannot make tests there.
> 
> You have to bring the interface 'UP' before it will detect link,
> with something like:  ifconfig eth2 up
> 
> Could that be the problem?
> 
> Ben

Hi Ben,

the situation is like this (exactly this works flawlessly with tulip):

- unplug all interfaces from the switches
- reboot box
- plug in _one_ interface 
- log into the box (yes, network works flawlessly)
- start keepalived
- now plug in rest of the interfaces
- watch keepalived do _nothing_ (seems no UP event shows up)

in comparison to:

- let all interfaces plugged in
- reboot box
- log in
- start keepalived
- watch it work as expected

Regards,
Stephan
