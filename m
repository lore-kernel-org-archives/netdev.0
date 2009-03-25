From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: igbvf: add new driver to support 82576 virtual functions
Date: Wed, 25 Mar 2009 02:03:29 -0700
Message-ID: <9929d2390903250203u42b50b54j2db3464967d48702@mail.gmail.com>
References: <20090324.233843.61607506.davem@davemloft.net>
	 <9929d2390903250145q2aae3046wb378d190576642c7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Yu Zhao <yu.zhao@intel.com>,
	Matthew Wilcox <willy@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:43092 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751173AbZCYJDb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 05:03:31 -0400
Received: by yx-out-2324.google.com with SMTP id 31so2941447yxl.1
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2009 02:03:29 -0700 (PDT)
In-Reply-To: <9929d2390903250145q2aae3046wb378d190576642c7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 25, 2009 at 1:45 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> On Tue, Mar 24, 2009 at 11:38 PM, David Miller <davem@davemloft.net> =
wrote:
>>
>> This breaks the build:
>>
>> drivers/net/igbvf/ethtool.c: In function 'igbvf_set_ringparam':
>> drivers/net/igbvf/ethtool.c:299: error: implicit declaration of func=
tion 'vmalloc'
>> drivers/net/igbvf/ethtool.c:299: warning: assignment makes pointer f=
rom integer without a cast
>> drivers/net/igbvf/ethtool.c:346: error: implicit declaration of func=
tion 'vfree'
>> --
>
> Sorry Dave, I thought this was called out earlier, but I see it was
> not. =C2=A0The igbvf driver requires the following patches applied to=
 your
> tree to have them compile. =C2=A0Last I heard, these SR-IOV patches w=
ere
> accepted for 2.6.30, in the PCI tree.
>
> Yu, can you confirm that these patches have been accepted for 2.6.30?
>
> Summary:
> http://marc.info/?l=3Dlinux-kernel&m=3D123751955907397&w=3D2
> Patches:
> http://marc.info/?l=3Dlinux-kernel&m=3D123751956107417&w=3D2
> http://marc.info/?l=3Dlinux-kernel&m=3D123751956207423&w=3D2
> http://marc.info/?l=3Dlinux-kernel&m=3D123751981407629&w=3D2
> http://marc.info/?l=3Dlinux-kernel&m=3D123751981507632&w=3D2
> http://marc.info/?l=3Dlinux-kernel&m=3D123751981707644&w=3D2
> http://marc.info/?l=3Dlinux-kernel&m=3D123751981607635&w=3D2
> http://marc.info/?l=3Dlinux-kernel&m=3D123751981607638&w=3D2
> http://marc.info/?l=3Dlinux-kernel&m=3D123751981707641&w=3D2

I confirmed that Jesse Barnes has these SR-IOV patches queued up for 2.=
6.30.
http://marc.info/?l=3Dlinux-kernel&m=3D123757169806111&w=3D2

--=20
Cheers,
Jeff
