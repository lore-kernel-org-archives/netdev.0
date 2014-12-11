From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: default enable sparse __CHECK_ENDIAN__ (was: Re: [PATCH v7 2/3]
 net: Add Keystone NetCP ethernet driver)
Date: Wed, 10 Dec 2014 19:04:59 -0800
Message-ID: <1418267099.18092.28.camel@perches.com>
References: <1417556503-22290-3-git-send-email-m-karicheri2@ti.com>
	 <20141209.131053.2026868499542642866.davem@davemloft.net>
	 <5488BB96.9070609@ti.com>
	 <20141210.204110.618599360537141819.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: m-karicheri2-l0cyMroinI0@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, linux-sparse-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Christopher Li <sparse-55XgFHCVCFZAfugRpC6u6w@public.gmane.org>,
	Michal Marek <mmarek-AlSwsSmVLrQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20141210.204110.618599360537141819.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-12-10 at 20:41 -0500, David Miller wrote:
> From: Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>
> > Are you referring to the static code analyser sparse that is invoked
> > through?
> You have to explicitly enable endian checking, it's not on by
> default.

There don't seem to be thousands of warnings anymore.

Maybe it's time to default enable it when using C=?

from: Documentation/sparse.txt:

The optional make variable CF can be used to pass arguments to sparse.  The
build system passes -Wbitwise to sparse automatically.  To perform endianness
checks, you may define __CHECK_ENDIAN__:

        make C=2 CF="-D__CHECK_ENDIAN__"

These checks are disabled by default as they generate a host of warnings.



--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
