From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V11 2/4] ptp: Added a clock that uses the eTSEC found
 on the MPC85xx.
Date: Thu, 24 Feb 2011 17:50:04 +0100
Message-ID: <20110224165004.GB15234@riccoc20.at.omicron.at>
References: <cover.1298447722.git.richard.cochran@omicron.at>
 <be1f5e801e8cd0145dd23aadae7c2055bb3c1d47.1298447722.git.richard.cochran@omicron.at>
 <20110223165058.GE14597@angua.secretlab.ca>
 <20110223112612.30071995@schlenkerla>
 <20110223175459.GH14597@angua.secretlab.ca>
 <20110223132444.65dfdda4@schlenkerla>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
To: Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110223132444.65dfdda4@schlenkerla>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 23, 2011 at 01:24:44PM -0600, Scott Wood wrote:
> Whatever string is used should be written into a binding document.
> 
> fsl,etsec-v1.6-ptp seems like it would be just as good for that purpose.
> 
> Even just fsl,etsec-ptp will identify the binding, though it's lacking in
> identifying the hardware (in the absence of access to the eTSEC ID
> registers).

I read the conversation, and I don't mind admitting that I do not
understand what you both are arguing/discussing about.

How should I set the strings?  Like this?

arch/powerpc/boot/dts/mpc8313erdb.dts:
	ptp_clock@24E00 {
		compatible = "fsl,mpc8313-etsec-ptp";
	}
arch/powerpc/boot/dts/mpc8572ds.dts:
	ptp_clock@24E00 {
		compatible = "fsl,mpc8572-etsec-ptp";
	} 
arch/powerpc/boot/dts/p2020ds.dts:
	ptp_clock@24E00 {
		compatible = "fsl,p2020ds-etsec-ptp";
	} 
arch/powerpc/boot/dts/p2020rdb.dts:
	ptp_clock@24E00 {
		compatible = "fsl,p2020rdb-etsec-ptp";
	} 

drivers/net/gianfar_ptp.c:

static struct of_device_id match_table[] = {
	{ .compatible = "fsl,mpc8313-etsec-ptp" },
	{ .compatible = "fsl,mpc8572-etsec-ptp" },
	{ .compatible = "fsl,p2020ds-etsec-ptp" },
	{ .compatible = "fsl,p2020rdb-etsec-ptp" },
	{},
};

Please let me know if this is what you meant.

Thanks,
Richard
