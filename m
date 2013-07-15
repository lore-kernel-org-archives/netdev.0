From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCHv2] am33xx: cpsw: default to ethernet hwaddr from efuse if not defined in dt
Date: Mon, 15 Jul 2013 07:31:18 +0200
Message-ID: <871u70bd95.fsf@dell.be.48ers.dk>
References: <1358461134-13452-1-git-send-email-jacmet@sunsite.dk>
	<50F8DA3A.3090406@ti.com> <51DAB39C.7090106@newflow.co.uk>
	<51E013D7.7060301@newflow.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mugunthan V N <mugunthanvnm@ti.com>, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	hvaibhav@ti.com, richardcochran@gmail.com, tony@atomide.com,
	michal.bachraty@gmail.com, michal.bachraty@streamunlimited.com
To: Mark Jackson <mpfj-list@newflow.co.uk>, tony@atomide.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <51E013D7.7060301@newflow.co.uk> (Mark Jackson's message of "Fri,
	12 Jul 2013 15:33:59 +0100")
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "Mark" == Mark Jackson <mpfj-list@newflow.co.uk> writes:

Hi,

 Mark> On 08/07/13 13:42, Mark Jackson wrote:
 >> On 18/01/13 05:14, Mugunthan V N wrote:
 >>> On 1/18/2013 3:48 AM, Peter Korsgaard wrote:
 >>>> When booting with CONFIG_ARM_APPENDED_DTB (either because of using an old
 >>>> U-Boot, not wanting the hassle of 2 files or when using Falcon fast boot
 >>>> mode in U-Boot), nothing updates the ethernet hwaddr specified for the
 >>>> CPSW slaves, causing the driver to use a random hwaddr, which is some times
 >>>> troublesome.
 >>>> 
 >>>> The am33xx has unique ethernet hwaddrs programmed in the efuse, so it makes
 >>>> more sense to default to these rather than random ones. Add a fixup step
 >>>> which adds mac-address dt properties using the efuse addresses if the DTB
 >>>> didn't contain valid ones.
 >>>> 
 >>>> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
 >>> 
 >>> This implementation looks fine.
 >>> Acked-by: Mugunthan V N <mugunthanvnm@ti.com>
 >> 
 >> Tested-by: Mark Jackson <mpfj-list@newflow.co.uk>

 Mark> Is this ever going to be put into the mainline code ?

Good question. Tony, could you please pick this up? It has been pending
since January and has a number of acks.

Do you want me to resend?

-- 
Bye, Peter Korsgaard
