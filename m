From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [RFC iproute2 0/8] RDMA tool
Date: Fri, 5 May 2017 16:17:54 +0300
Message-ID: <20170505131754.GH22833@mtr-leonro.local>
References: <20170504180216.7665-1-leon@kernel.org>
 <20170505085457.0029edc9@griffin>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="DMefDzZywwCHZelG"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Doug Ledford <dledford@redhat.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Ram Amrani <ram.amrani@cavium.com>,
        Bart Van Assche <Bart.VanAssche@sandisk.com>,
        Sagi Grimberg <sagi@grimberg.me>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Christoph Hellwig <hch@lst.de>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Linux RDMA <linux-rdma@vger.kernel.org>,
        Linux Netdev <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:57464 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751437AbdEENRz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 5 May 2017 09:17:55 -0400
Content-Disposition: inline
In-Reply-To: <20170505085457.0029edc9@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--DMefDzZywwCHZelG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, May 05, 2017 at 08:54:57AM +0200, Jiri Benc wrote:
> On Thu,  4 May 2017 21:02:08 +0300, Leon Romanovsky wrote:
> > In order to close object model, ensure reuse of existing code and make this
> > tool usable from day one, we decided to implement wrappers over legacy sysfs
> > prior to implementing netlink functionality. As a nice bonus, it will allow
> > to use this tool with old kernels too.
>
> This sounds wrong. We don't support legacy ioctl interface for the 'ip'
> command, either. I think rdma should be converted to netlink first and
> the new tool should only use netlink.

RDMA in slightly different situation than "ip" tool was. "ip" was implemented
when tools like ifconfig existed. It allowed to old and new systems to be
configured to some degree. In RDMA community, there are no similar tools like
"ifconfig". Implementation in netlink-only interface will leave old systems without
common tool at all.

As an upstream-oriented person, I personally fine with that, but anyway would
like to get wider agreement/disagreement on that, before removing sysfs
parsing logic from the rdmatool.

Thanks

>
>  Jiri

--DMefDzZywwCHZelG
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkMe4IACgkQ5GN7iDZy
WKf2WQ/8DkPETSwi9IYEu+gckJiQoOY57lXkGb5MqjWm95gEOyVXvYPM1GMSL8O5
z55zXrlkpSf4PSW/wtuZ+rZdLg/IbU3dZzv1zGln9MlAcu9mpAxca2FfLIcKpXeM
fTWdHcwbxFcODSm4IhwU4A12XTNPcXFsYbmhqVIqUSyT06+XYLcgabGCiQg9fvCk
6VuHuJrPu0WcSBujytIVsOVfc31YwhURcvMjJNXauHpZFxUU9/0Wfkny9mvXVKgA
UxRtts9OplezKXGC0i0T2lVAmqh84AD4fX06KBx9Lt0FG8NFds9J+31CwtxpEDch
BrnWkWuMO6zlN8OiLliQpKwn/nJ9AEW0riKIb3Kxu/4JT4I6EM0Rf7Nem6/pznl2
yMTZhfyz9Y/scq7q2Z0HtWhhW71n9cpYknqA62cF3dUcfmAh8QA6/coiqi0Cr8vy
dvivF4cpIchJCYfTPqc6wdA3Ve0hd32v6+ZGcftLRQyOfYZ6VPLCtrwBbmpVvqs9
3QSwO18+dGOfGpwyIezbR019Nm1ZECNOTJtnKYaY8AKeXOpZa/2UnmGJGcv17y0b
eXwqEoJjr/adPqz329v4UaWjDTUamwWJvdujgoEAt8MAaiT1kCWLr/zL5knEEwlY
eNnMh7qZlg1WjRTzDFQ07EOxTESoF80q8m93CNm3F5vdfBHf768=
=/GCt
-----END PGP SIGNATURE-----

--DMefDzZywwCHZelG--
