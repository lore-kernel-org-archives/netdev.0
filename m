From: jamal <hadi@cyberus.ca>
Subject: Re: patch: annoying u32 double listing
Date: 07 Feb 2005 08:49:29 -0500
Message-ID: <1107784168.1054.58.camel@jzny.localdomain>
References: <1107719343.1055.22.camel@jzny.localdomain>
	 <42068EA2.6030507@trash.net> <1107727330.1053.44.camel@jzny.localdomain>
	 <4206A58A.9050909@trash.net>  <20050206223646.239c0d77.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050206223646.239c0d77.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I believe the last patch is correct. I can explain the many patches ;->
Call it the excitement to fix it if you may.
Its a problem that has existed for many years and many users have
complained about it but noone has really zoned on the cause fatale.
The 90% of it was really the patch i posted which zoned on it - for
years theory was the fix was in tc(user space). 
Patricks reincarnation got it to 95% and his second one got it to 100%.
IMO: Push it in, let some user whine.

cheers,
jamal

On Mon, 2005-02-07 at 01:36, David S. Miller wrote:
> On Mon, 07 Feb 2005 00:17:30 +0100
> Patrick McHardy <kaber@trash.net> wrote:
> 
> > jamal wrote:
> > 
> > >I should have caught that output missing divisor ;->
> > >Dave please apply Patricks version. Should probably apply cleanly on
> > >2.4.x as well.
> > >
> > My last patch has a similar problem, new hash tables added with
> > "u32 divisor .." are skipped while walking. This patch is better
> > tested and should be fine. Applies to 2.4 and 2.6.
> 
> After seeing 4+ revisions of the same bug fix on the same day,
> let's let this sink for another day to make sure it's really
> the final version :-)
> 
