From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH v2 09/13] net: Rework pasemi_mac driver to use of_mdio
	infrastructure
Date: Sun, 22 Mar 2009 12:36:44 -0600
Message-ID: <fa686aa40903221136k5a926381u69fe6e57b927d1d2@mail.gmail.com>
References: <20090321222047.20493.87335.stgit@localhost.localdomain>
	 <20090321222901.20493.67103.stgit@localhost.localdomain>
	 <20090322154710.GA6473@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	afleming@freescale.com, galak@kernel.crashing.org,
	davem@davemloft.net
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:17753 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201AbZCVSgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2009 14:36:46 -0400
Received: by yw-out-2324.google.com with SMTP id 5so1822006ywb.1
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2009 11:36:44 -0700 (PDT)
In-Reply-To: <20090322154710.GA6473@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 22, 2009 at 9:47 AM, Olof Johansson <olof@lixom.net> wrote:
> On Sat, Mar 21, 2009 at 04:29:01PM -0600, Grant Likely wrote:
>> From: Grant Likely <grant.likely@secretlab.ca>
>>
>> This patch simplifies the driver by making use of more common code.
>
> Did you ever try building it? pasemi_defconfig gives me:

No.  I mentioned it in the series header email, but not in the patch
description.  My 64bit build environment is broken at the moment so I
couldn't build test the pasemi patch.  All the others are build
tested.  I'll have it sorted out before I post v3.

> drivers/net/pasemi_mac.c: In function 'pasemi_mac_phy_init':
> drivers/net/pasemi_mac.c:1102: error: implicit declaration of function 'of_phy_connect'
> drivers/net/pasemi_mac.c:1103: warning: assignment makes pointer from integer without a cast
> drivers/net/pasemi_mac.c:1114: warning: label 'err' defined but not used
> drivers/net/pasemi_mac.c:1092: warning: unused variable 'ret'
> drivers/net/pasemi_mac.c:1091: warning: unused variable 'r'
> drivers/net/pasemi_mac.c:1090: warning: unused variable 'prop'
> drivers/net/pasemi_mac.c:1089: warning: unused variable 'ph'
> make[2]: *** [drivers/net/pasemi_mac.o] Error 1
>
> The changes needed are trivial, include <linux/of_mdio.h> and remove the
> variables, label and following code. I could send a patch but that's likely
> more of a hassle than you fixing it up yourself?

Yeah, I'll fix it.  Thanks for the testing.

> Otherwise, with the above changes, seems to test out ok on my Electra.
> When you checkin the changes, feel free to add:

Awesome.  Thanks for the testing.

g.

-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
