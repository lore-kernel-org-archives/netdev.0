From: Jeff Mahoney <jeffm@suse.com>
Subject: Re: [PATCH RESEND #2] ipg: Remove device claimed by dl2k from pci
 id table
Date: Mon, 08 Mar 2010 15:58:56 -0500
Message-ID: <4B956510.5020604@suse.com>
References: <4B9563B6.9070803@suse.com> <20100308.125700.04760925.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, sorbica@icplus.com.tw, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:49199 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752323Ab0CHU6z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Mar 2010 15:58:55 -0500
In-Reply-To: <20100308.125700.04760925.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 03/08/2010 03:57 PM, David Miller wrote:
> From: Jeff Mahoney <jeffm@suse.com>
> Date: Mon, 08 Mar 2010 15:53:10 -0500
> 
>> ipg: Remove device claimed by dl2k from pci id table
>>
>>  This patch removes D-Link DGE-550T PCI ID (1186:4000) from the ipg
>>  driver. The ipg driver is for IP2000-based cards and the DGE-550T is
>>  a DL2000-based card. The driver loads and works for a few moments, but
>>  once a real workload is applied it stops operating. The ipg driver
>>  claimed this ID since it was introduced in 2.6.24 and it's forced many
>>  users to blacklist it.
>>
>>  The correct driver for this hardware is the dl2k driver, which has been
>>  claiming this PCI ID since the 2.4 days.
>>
>> Signed-off-by: Jeff Mahoney <jeffm@suse.com>
> 
> Please stop re-submitting this, it's already in the tree:


Heh ok. You just asked me to re-send it since it was corrupted. I never
got a response when I posted it the first time. Sorry for the noise.

- -Jeff

> commit 25cca5352712561fba97bd37c495593d641c1d39
> Author: Jeff Mahoney <jeffm@suse.com>
> Date:   Thu Feb 11 10:26:38 2010 +0000
> 
>     ipg: Remove device claimed by dl2k from pci id table
>     
>     This patch removes D-Link DGE-550T PCI ID (1186:4000) from the ipg
>     driver. The ipg driver is for IP2000-based cards and the DGE-550T is
>     a DL2000-based card. The driver loads and works for a few moments, but
>     once a real workload is applied it stops operating. The ipg driver
>     claimed this ID since it was introduced in 2.6.24 and it's forced many
>     users to blacklist it.
>     
>     The correct driver for this hardware is the dl2k driver, which has been
>     claiming this PCI ID since the 2.4 days.
>     
>     Signed-off-by: Jeff Mahoney <jeffm@suse.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 


- -- 
Jeff Mahoney
SUSE Labs
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.13 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org/

iEYEARECAAYFAkuVZRAACgkQLPWxlyuTD7LlYQCdHUd1KJTaHAmYc+MC822H/3Or
qqEAn31TdDxLMiO4sUUgWtoTGZKCfh1j
=SJDe
-----END PGP SIGNATURE-----
