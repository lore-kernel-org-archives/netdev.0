From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: Prism54 WPA Support - wpa_supplicant - Linux general wpa support
Date: Thu, 3 Jun 2004 09:52:33 -0700
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Message-ID: <20040603165233.GC8770@bougret.hpl.hp.com>
References: <20040602071449.GJ10723@ruslug.rutgers.edu>
	<20040602132313.GB7341@jm.kir.nu>
	<20040602155542.GC24822@ruslug.rutgers.edu>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: Netdev <netdev@oss.sgi.com>, hostap@shmoo.com,
	prism54-devel@prism54.org, Jeff Garzik <jgarzik@pobox.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20040602155542.GC24822@ruslug.rutgers.edu>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://sisyphus.iocaine.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 02, 2004 at 11:55:42AM -0400, Luis R. Rodriguez wrote:
> On Wed, Jun 02, 2004 at 06:23:14AM -0700, Jouni Malinen wrote:
> > 
> > The first thing I would like to see is an addition to  Linux wireless
> > extensions for WPA/WPA2 so that we can get rid of the private ioctls in
> > the drivers. Even though these can often be similar, it would be nice to
> > just write one driver interface code in wpa_supplicant and have it
> > working with all Linu drivers.. I hope to find some time to write a
> > proposal for this.
> 
> I agree :). Jean? *poke*
> 
> 	Luis

	The initial plan was for me to get more familiar with WPA, but
this keep slipping (partly due to family matters). HP did follow my
suggestions and use IPsec internally, which also explain why I'm in no
hurry. There was some stuff I wanted to "improve" in the API design,
but I guess that if I can't deliver a patch, I'd better shut up and
try to avoid being a bottleneck.
	At this point, I think that Jouni is our best expert on the
subject, and the fact that many driver has reused his API means that
his API is sensible and flexible enough.
	So, the plan would be to take Jouni's API as is (or with minor
modifications) and stuff that in wireless.h. I don't believe that the
tools themselves need to be modified, because wpa_supplicant is the
sole user of those ioctls.
	If you are all happy with that, then I'll just do it.

	Have fun...

	Jean
