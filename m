From: Werner Almesberger <wa@almesberger.net>
Subject: Re: [Fwd: [ANNOUNCE] Layer-7 Filter for Linux QoS]
Date: Sat, 24 May 2003 04:22:46 -0300
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030524042246.B29146@almesberger.net>
References: <Pine.LNX.4.40.0305221019240.29409-100000@phil.home.phil> <3ECCE151.8000903@ethanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Philippe Biondi <biondi@cartel-securite.fr>,
	Jamal Hadi <hadi@shell.cyberus.ca>,
	Martin Josefsson <gandalf@wlug.westbo.se>,
	"David S. Miller" <davem@redhat.com>, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Ethan Sommer <sommere@ethanet.com>
Content-Disposition: inline
In-Reply-To: <3ECCE151.8000903@ethanet.com>; from sommere@ethanet.com on Thu, May 22, 2003 at 09:40:17AM -0500
List-Id: netdev.vger.kernel.org

Ethan Sommer wrote:
> Philippe Biondi wrote:
>> For every NDFA, there exist a DFA that recognize the same language.
>> So, it is possible.
>>
> 
> That is true only if you only care if either are matched. Not if you 
> care which is matched. By combining them you lose the ability to tell 
> which matched.

"exists a DFA" doesn't mean that there is only one :-) Typically,
there are a lot of DFAs for each NFA, usually an infinite number
of them. And among them are also those that don't combine states
you don't want to combine.

>> The question is : will we have enough memory to store a DFA that recognize
>> a big regexp ? The answer is : let loose some speed and use NDFA.

Also simpler DFAs would be interesting, e.g. acyclic ones. Size
shouldn't be a problem for them. In fact, for "traditional"
classification (i.e. well below layer 7), that's really all you
need.

- Werner

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina         wa@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
