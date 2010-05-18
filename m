From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 3/3] ptp: Added a clock that uses the eTSEC found on
	the MPC85xx.
Date: Tue, 18 May 2010 08:36:08 +0200
Message-ID: <20100518063608.GA2720@riccoc20.at.omicron.at>
References: <cover.1273855016.git.richard.cochran@omicron.at>
	<ee6c3edca3ee6aa86565e59da999375f79c9de1b.1273855017.git.richard.cochran@omicron.at>
	<4BED8C91.8020107@freescale.com>
	<20100517082757.GA9703@riccoc20.at.omicron.at>
	<4BF18582.6000500@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
To: Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4BF18582.6000500-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, May 17, 2010 at 01:05:54PM -0500, Scott Wood wrote:
> >>> >+  - tmr_fiper1   Fixed interval period pulse generator.
> >>> >+  - tmr_fiper2   Fixed interval period pulse generator.
> >>
> 
> MPC8572 and P2020 have fiper3 as well.

I doubt they really have a third fiper.

First of all, this signal is not routed anywhere on the boards. Also,
according to the documentation, it has no bit in the TMR_CTRL or the
TMR_TEMASK registers. Unless there is a bit in TMR_TEMASK, you cannot
get an interrupt from it.

If you cannot use the signal externally (in the "real" world) and you
cannot get an interrupt, what good is it to have such a periodic
signal? Polling the bit in the TMR_TEVENT to see when a pulse occurs
seems pointless.

Scott, you have connections, right? Can you clarify this for me?

Thanks,

Richard
