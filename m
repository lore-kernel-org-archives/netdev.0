From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC/PATCH] IMQ port to 2.6
Date: 31 Jan 2004 16:49:24 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1075585764.1035.192.camel@jzny.localdomain>
References: <20040126001102.GA12303@usr.lcm.msu.ru>
	 <1075086588.1732.221.camel@jzny.localdomain>
	 <20040126093230.GA17811@usr.lcm.msu.ru>
	 <1075124312.1732.292.camel@jzny.localdomain>
	 <20040126135545.GA19497@usr.lcm.msu.ru>
	 <1075127396.1746.370.camel@jzny.localdomain>
	 <20040131185231.GA2608@usr.lcm.msu.ru>
	 <1075580812.1035.83.camel@jzny.localdomain>
	 <20040131205326.GA3089@usr.lcm.msu.ru>
	 <1075584318.1033.159.camel@jzny.localdomain>
	 <20040131213236.GA3451@usr.lcm.msu.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Vladimir B. Savkin" <master@sectorb.msk.ru>
In-Reply-To: <20040131213236.GA3451@usr.lcm.msu.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2004-01-31 at 16:32, Vladimir B. Savkin wrote:


> Yes, if you define "flow" as all traffic to one client.
>
> Actually, I use two-level hierarchy: in every flow in above sense
> each micro-flow receives a fair amount of bandwidth (approximatly,
> using sfq).

Ok. 

> > [This can only be achieved by a non-work conserving scheduler].
> 
> Yes.

Still a few rough edges, so bear with me:
Would you not be able to achieve the same if you used the marking scheme
i described earlier on eth0 and used HTB or HFSC or CBQ (as non-work
conserving) on eth1/2? I was suggesting prio before and you pointed you
the queues will never be full for that to have any value. 

cheers,
jamal
