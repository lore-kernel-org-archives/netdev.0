From: jamal <hadi@cyberus.ca>
Subject: Re: _High_ CPU usage while routing (mostly) small UDP packets
Date: 07 Dec 2004 23:31:58 -0500
Message-ID: <1102480318.1050.16.camel@jzny.localdomain>
References: <20041206205305.GA11970@soohrt.org>
	 <20041207211035.GA20286@quickstop.soohrt.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Robert Olsson <Robert.Olsson@data.slu.se>, P@draigBrady.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Karsten Desler <kdesler@soohrt.org>
In-Reply-To: <20041207211035.GA20286@quickstop.soohrt.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-12-07 at 16:10, Karsten Desler wrote:
> Karsten Desler <kdesler@soohrt.org> wrote:
> > Current packetload on eth0 (and reversed on eth1):
> >   115kpps tx
> >   135kpps rx
> 
> I totally forgot to mention: There are approximately 100k concurrent
> flows.

;-> Aha. That would make a huge difference. I know of noone
who has actually done this level of testing. I have tried upto about 50K
flows myself in early 2.6.x and was eventually compute bound.
Really try compiling out totaly iptables/netfilter - it will make a
difference.
You may also want to try something like LC trie algorithm that Robert
and co are playing with to see if it makes a difference with this many
flows. 

cheers,
jamal
