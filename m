From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 10/12] ptp: Added a clock that uses the eTSEC found on
	the MPC85xx.
Date: Wed, 16 Jun 2010 08:45:41 +0200
Message-ID: <20100616064541.GD2887@riccoc20.at.omicron.at>
References: <cover.1276615626.git.richard.cochran@omicron.at>
	<041faf3cb6ecbedf8f3ff2104914f91d2a24fc4d.1276615626.git.richard.cochran@omicron.at>
	<AANLkTikFc15j-Qhw9M2CnKLKq58Wi1xD7E2dtVNsVgeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTikFc15j-Qhw9M2CnKLKq58Wi1xD7E2dtVNsVgeA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Tue, Jun 15, 2010 at 11:20:41AM -0600, Grant Likely wrote:
> 
> Is this header file used by anything other than gianfar_ptp.c?  If
> not, then roll the two files together.

I anticipate that it might be necessary to share the header's contents
with gianfar.c one day.

> Use dash ('-') not underscore ('_') in property names.

Okay, can do.

> If you encode this value as a string, then it will be friendly for humans too.

Okay.

> I could use more explication here.  Is this a divider value?
> Computers are good at making calculations, and the driver can obtain
> the clock frequency supplied to the device.  It may be more useful to
> specify here the desired frequency rather than the divider.  Certainly
> more human-friendly too.

It is not that simple. The basic algorithm is described in the text,
and anyone wanting to use the eTSEC for PTP will have to consider the
issue themselves, since it is a design issue with a few tradeoffs
related to the board layout. It is really too thorny to do in the
driver automatically.

I can post a tcltk calculator script for finding appropriate values,
in anyone would like to see it.

> > +static struct etsects the_clock;
> 
> Will there ever be multiple instances of this device?

No, never. If you consider how PTP works, there can only be one clock
per system.

> Consider of_iomap(), it will simplify the code a bit.

> Move ptp_gianfar_exit() definition here so it is immediately before
> the module_exit() line.

Okay.


Thanks for the review,

Richard
