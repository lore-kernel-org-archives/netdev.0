From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] (2/4) packet scheduler bad TDIFF_SAFE in csz
Date: 29 Jun 2004 18:43:45 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1088549025.1046.12.camel@jzny.localdomain>
References: <20040629140016.4afeb36b@dell_ss3.pdx.osdl.net>
	 <20040629144506.0649d217.davem@redhat.com>
	 <1088547756.1040.5.camel@jzny.localdomain>
	 <20040629152822.4fa2e1c4.davem@redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040629152822.4fa2e1c4.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Sounds like good logic to me.
BTW, that jiffies fix, statemnt from Steve:
> The downside is the overhead of a function call, and a cache miss in >
>get_jiffies_64.

Is this overhead on 32 bit machines or applies on 64 bit as well?
Note that code is used in the fast path.

cheers,
jamal
On Tue, 2004-06-29 at 18:28, David S. Miller wrote:
> On 29 Jun 2004 18:22:37 -0400
> jamal <hadi@cyberus.ca> wrote:
> 
> > That scheduler is only a relic.
> > Nobody uses it ;-> Check the cofig help.
> > Pretty sure if you study it youll find a lot more bugs.
> 
> Right, but it is good that we fix the obvious ones when
> we can.  Stephen's fix resulted in being able to simplify
> some PSCHED_* macros significantly.
> 
> 
