From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: Please pull 'upstream-jgarzik' branch of wireless-2.6
Date: Tue, 18 Dec 2007 09:24:49 +0800
Message-ID: <1197941089.2857.252.camel@debian.sh.intel.com>
References: <20071216043419.GF3096@tuxdriver.com>
	 <47670514.4030204@garzik.org>  <476708EF.10403@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:1034 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751327AbXLRBex (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 20:34:53 -0500
In-Reply-To: <476708EF.10403@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2007-12-17 at 18:40 -0500, Jeff Garzik wrote:
> drivers/net/wireless/iwlwifi/iwl3945-base.c: In function=20
> =A1=AEiwl3945_alive_start=A1=AF:
> drivers/net/wireless/iwlwifi/iwl3945-base.c:6285: error: implicit=20
> declaration of function =A1=AEiwl_rate_control_unregister=A1=AF
> make[4]: *** [drivers/net/wireless/iwlwifi/iwl3945-base.o] Error 1
> make[3]: *** [drivers/net/wireless/iwlwifi] Error 2
> make[2]: *** [drivers/net/wireless] Error 2
> make[1]: *** [drivers/net] Error 2
> make: *** [drivers] Error 2

We changed the namespace between 2.6.24 and upstream. So
iwl_rate_control_unregister should be renamed to
iwl3945_rate_control_unregister when the patch is merged from
fix-jgarzik to upstream-jgarzik. The same thing is also for
iwl4965_rate_control_unregister.

> I'll leave it there and assume that you will send a fix --on top of--=
=20
> netdev#upstream ...

I assume John will do it.

Thanks,
-yi

