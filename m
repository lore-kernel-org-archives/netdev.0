From: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Subject: Re: [PATCH v4] smc91x: add devicetree support
Date: Wed, 26 Jan 2011 08:32:52 -0700
Message-ID: <AANLkTimCMpB+mOHv+8GMOkFF0qMh+bVxr56_-8r3EOqc@mail.gmail.com>
References: <20110125.194532.71125517.davem@davemloft.net>
	<1296019325-17801-1-git-send-email-thomas@wytron.com.tw>
	<alpine.LFD.2.00.1101261004560.8580@xanadu.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: nios2-dev-1eJk0qcHJCcaeqlQEoCUNoJY59XmG8rH@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Nicolas Pitre <nico-vtqb6HGKxmzR7s880joybQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <alpine.LFD.2.00.1101261004560.8580-QuJgVwGFrdf/9pzu0YdTqQ@public.gmane.org>
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

On Wed, Jan 26, 2011 at 8:17 AM, Nicolas Pitre <nico-vtqb6HGKxmzR7s880joybQ@public.gmane.org> wrote:
> On Wed, 26 Jan 2011, Thomas Chou wrote:
>
>> Signed-off-by: Thomas Chou <thomas-SDxUXYEhEBiCuPEqFHbRBg@public.gmane.org>
>> ---
>> v2 specify part numbers in compat as Grant suggested.
>> v3 more specific part name.
>> v4 include match table only for OF as David suggested.
>
> The smc91x driver relies on many parameters which are platform specific,
> such as the bus width capabilities, register spacing due to special bus
> wiring, interrupt signal level, LED configuration, whether or not to
> configure the chip with a wait state, etc. =A0Will the device tree support
> take care of those things?

Short answer, yes

In general bindings are written and documented as they are needed.  In
this specific case,yes the device configuration should be encoded into
the device tree node.  It is okay for now to not wire up any of that
configuration if the defaults work for Thomas' platform, but to be
useful in the long run they do need to be added.

Typically a block or function call is added to the drivers .probe hook
to decode device tree data if the of_node pointer is set.

g.

-- =

Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
