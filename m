From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: BUG: Bisected Gianfar in bridge not forwarding packets (was:
 3.0-rc1 Bridge not forwarding unicast packages)
Date: Wed, 10 Aug 2011 13:48:12 +0100
Message-ID: <1312980492.2591.1261.camel@deadeye>
References: <CAMvAeqOA0=FnjB2oPPCEYpkXdKrmqOs+MwAqszV5sTGys_a3mQ@mail.gmail.com>
	 <20110810090014.GB1909@minipsycho.brq.redhat.com>
	 <CAMvAeqO2bLaPwmdW+c+7hz-ec=-tF6Z0EFBv=FA7+rU_QZ_wDA@mail.gmail.com>
	 <CAMvAeqM-oH1UzxEp9PgO6ZP-AKtqosuMg5za25_X8DpPJMDX2w@mail.gmail.com>
	 <20110810111947.GC1909@minipsycho.brq.redhat.com>
	 <CAMvAeqOZ9OoV5KxTbn0+sPxJ=AkSrb__31GShVshDkX6NUXgNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>, shemminger@vyatta.com,
	sebastian.belden@googlemail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: Michael Guntsche <mguntsche@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMvAeqOZ9OoV5KxTbn0+sPxJ=AkSrb__31GShVshDkX6NUXgNw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-08-10 at 13:51 +0200, Michael Guntsche wrote:
[...]
> Jiri, there seems to be another bug lingering in the bridge code,
> which might cause this problem in the first place but I am not really
> sure. I looked at the ethtool output some more and I noticed that some
> features were enabled on the Bridge which should be off.
[...]

That's an intentional change.  There are software fallbacks for TX
checksumming and VLAN tag insertion.  Bridge devices (and some other
software devices) now always advertise them so that the fallback is not
used until and unless it is known that the real output device doesn't
support the feature.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
