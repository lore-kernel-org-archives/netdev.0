From: bert hubert <ahu@ds9a.nl>
Subject: Re: off by one error in 3des cbc keying
Date: Mon, 11 Nov 2002 11:01:09 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021111100109.GB18677@outpost.ds9a.nl>
References: <20021110111507.GA31188@outpost.ds9a.nl> <200211110151.EAA26095@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200211110151.EAA26095@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[alexey's nameserver is off, cc to netdev@oss.sgi.com, perhaps he sees it
there]

On Mon, Nov 11, 2002 at 04:51:36AM +0300, kuznet@ms2.inr.ac.ru wrote:

> Yes, connect() is broken... The patch is enclosed. Alternatively, you
> could allow connections to remote isakmp ports via policy.

Ok, with careful tuning, it will work now. But not for the general case.

If a policy is setup that only applies to ICMP, IKE converges and works (as
it works over UDP).

I wonder, is 'incoming bypass' implemented yet? If there is an incoming
policy, racoon does not see any traffic.

Key refreshing/updating doesn't appear to work either, after they key has
expired, all bets are off.

Regards,

bert

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
