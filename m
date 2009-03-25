From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH v3] igbvf: add new driver to support 82576
	virtual functions
Date: Wed, 25 Mar 2009 15:00:18 -0700
Message-ID: <9929d2390903251500xd0ceeb3n31779e9e8f72dbde@mail.gmail.com>
References: <20090325215248.28529.62295.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:47060 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753466AbZCYWAV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 18:00:21 -0400
Received: by yw-out-2324.google.com with SMTP id 5so243411ywb.1
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2009 15:00:19 -0700 (PDT)
In-Reply-To: <20090325215248.28529.62295.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 25, 2009 at 2:52 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
>
> This adds an igbvf driver to handle virtual functions provided by the
> igb driver when SR-IOV has been enabled. =C2=A0A virtual function is =
a
> lightweight pci-e function that supports a single queue and shares
> resources with the 82576 physical function contained within the igb
> driver.
>
> To spawn virtual functions from the igb driver all that is needed is =
to
> issue a echo X > /sys/class/ethY/num_vfs. =C2=A0X can be a value betw=
een 0 and
> 7, 0 will disable SR-IOV functionality for the port and is the defaul=
t. =C2=A0If
> the num_vfs sysfs entry is not present then the device does not have =
SR-IOV
> capability enabled either in software or hardware.
>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---

Only difference between v2 and v3 is the addition of the following line

> +#include <linux/vmalloc.h>

into drivers/net/igbvf/ethtool.c.  We verified that this fixes the
compilation issues on PPC.

--=20
Cheers,
Jeff
