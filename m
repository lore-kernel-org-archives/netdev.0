From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC PATCH 0/3] net: dsa: Complete and fix the dsa unbinding
Date: Thu, 1 Oct 2015 13:20:44 -0400
Message-ID: <20151001172044.GA25785@ketchup.mtl.sfl>
References: <560B9B70.6030202@baylibre.com>
 <560C1F5A.5070506@gmail.com>
 <560D4BDE.3080400@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	andrew@lunn.ch, linux@roeck-us.net
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <560D4BDE.3080400@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Neil,

On Oct. Thursday 01 (40) 05:06 PM, Neil Armstrong wrote:
> On 09/30/2015 07:43 PM, Florian Fainelli wrote:
> > On 30/09/15 01:21, Neil Armstrong wrote:
> >> In order to cleanly unbind the dsa core, either as a module removal,
> >> or a platform device unbind, switch the allocation the their devm_
> >> counterparts and complete the destroy functions.
> >>
> >> The last patch is an experimental way to exit the probe when no
> >> switch is found in the discover process.
> >>
> >> The patches are based on the current net-next.
> > 
> > I looked at the patches and they bring DSA in a better direction. For
> > future submissions, could you CC people who recently worked on DSA, like
> > Andrew Lunn, Guenter Roeck, Vivien Didelot and myself? We can typically
> > give your patches a try fairly quickly.
> > 
> > In case you are seriously considering making DSA a loadable module,
> > there were an earlier attempt here:
> > 
> > http://comments.gmane.org/gmane.linux.network/345803
> > 
> > Thanks!
> > 
> >>
> >> Neil Armstrong (3):
> >>   net: dsa: Use devm_ prefixed allocations
> >>   net: dsa: complete dsa_switch_destroy calls
> >>   net: dsa: exit probe if no switch were found
> >>
> >>  net/dsa/dsa.c | 67 ++++++++++++++++++++++++++++++++++++++++++++++++++++-------
> >>  1 file changed, 60 insertions(+), 7 deletions(-)
> >>
> > 
> > 
> Hi All,
> 
> Thanks for the tests and reviews.
> 
> My first intent is to make dynamic unbind/bind reliable, the reliable loadable module support
> is a more complex target, but starting with unbind is a simpler start.
> 
> Should I re-post with the missing people, the Tested-by & without the RFC tag ?

I didn't take a look at it, but given Florian's feedback, it seems to
make sense, so I'd suggest to resend it without the RFC prefix.

If a patch in the serie got a "Tested-by:" or whatever tag, include it
when resending, only if you didn't modify this patch in the meantime.

Thanks,
-v
