From: Nico Schottelius <nico-linux-20111201@schottelius.org>
Subject: Re: BCM43224 hanging [3.2.0-rc5]
Date: Sat, 31 Dec 2011 12:48:26 +0100
Message-ID: <20111231114826.GD2305@ethz.ch>
References: <20111201224851.GB20536@ethz.ch>
 <4ED8B610.2010703@broadcom.com>
 <20111202150128.GC3096@schottelius.org>
 <20111207190821.GA1775@schottelius.org>
 <20111212181619.GD1975@schottelius.org>
 <20111214112148.GE3191@ethz.ch>
 <20111222102408.GA2643@schottelius.org>
 <4EF32E4B.7050307@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nico Schottelius <nico-linux-20111201@schottelius.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	b43-dev@lists.infradead.org, Greg KH <gregkh@suse.de>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4EF32E4B.7050307@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Arend,

Arend van Spriel [Thu, Dec 22, 2011 at 02:19:07PM +0100]:
> On 12/22/2011 11:24 AM, Nico Schottelius wrote:
> > Update:
> > 
> > - dmesg with hanging logs
> > - The hang problem seems to happen ONLY with a specific access point: c8:6c:87:a9:df:a9
> >   -> this is a zyxel P-2802HWL-I1, running at channel 13, with WPA2-PSK.
> >   -> If you need more information, just let me know
> > - Using wlan with the Samsung S2 as access point seems to work fine
> 
> Is the Samsung AP also on channel 13? If not, could you try it?

No it's not and I cannot change it. But I changed the other AP
from 13 to channel 3 and now the hang issue is gone. So this is
definitely related to the specific frequence.

Hope this is enough information to get it fixed evetually :-)

Cheers,

Nico

-- 
PGP key: 7ED9 F7D3 6B10 81D7 0EC5  5C09 D7DC C8E4 3187 7DF0
