From: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Subject: Re: [PATCH 12/12] ptp: Added a clock driver for the National
	Semiconductor PHYTER.
Date: Wed, 16 Jun 2010 09:10:42 -0600
Message-ID: <AANLkTilYBL6gpeg5Yp0wOmqwIo3K5YKW4mtVlE2p6jkp@mail.gmail.com>
References: <cover.1276615626.git.richard.cochran@omicron.at>
	<37f5015b186bdd51f8451ade042f90c8b39a5cc8.1276615626.git.richard.cochran@omicron.at>
	<AANLkTilqd-wxqMWDxssC-XMDJqZ8iIiSrvp2t8xARAQV@mail.gmail.com>
	<20100616100539.GA3569@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20100616100539.GA3569-7KxsofuKt4IfAd9E5cN8NEzG7cXyKsk/@public.gmane.org>
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

On Wed, Jun 16, 2010 at 4:05 AM, Richard Cochran
<richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Tue, Jun 15, 2010 at 12:49:13PM -0600, Grant Likely wrote:
>> Won't this break things for existing DP83640 users?
>
> Nope, the driver was only added five patches ago, and it only offers
> the timestamping stuff. The standard PHY functions just call the
> generic functions, so the PHY works fine even without this driver.
>
>> > +static struct ptp_clock *dp83640_clock;
>> > +DEFINE_SPINLOCK(clock_lock); /* protects the one and only dp83640_clo=
ck */
>>
>> Why only one? =A0Is it not possible to have 2 of these PHYs in a system?
>
> Yes, you can have multiple PHYs, but only one PTP clock.
>
> If you do use multiple PHYs, then you must wire their clocks together
> and adjust the PTP clock on only one of the PHYs.
>
>
> Thanks for your other comments,

You're welcome.  Make sure to cc: linux-kernel on your next posting.
I commented on what I could, but there is a lot of code outside my
areas of expertise.  In particular the time keeping code needs to be
looked at by the maintainers in that area.

Cheers,
g.
