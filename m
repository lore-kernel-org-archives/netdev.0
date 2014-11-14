From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e100: fix typo in MDI/MDI-X eeprom check in e100_phy_init
Date: Fri, 14 Nov 2014 09:17:39 -0800
Message-ID: <CAL3LdT5yEg1MqDyigzFpfPkpFv8ST09uPYSEwqaKAypEvDwHeQ@mail.gmail.com>
References: <1415980770-5467-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Dave Miller <davem@davemloft.net>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Malli Chilakala <mallikarjuna.chilakala@intel.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:41986 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161125AbaKNRRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 12:17:40 -0500
Received: by mail-ob0-f182.google.com with SMTP id nt9so14046232obb.13
        for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 09:17:40 -0800 (PST)
In-Reply-To: <1415980770-5467-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 14, 2014 at 7:59 AM, John W. Linville
<linville@tuxdriver.com> wrote:
> Although it doesn't explicitly say so, commit 60ffa478759f39a2 ("e100:
> Fix MDIO/MDIO-X") appears to be intended to revert the earlier commit
> 648951451e6d2d53 ("e100: fixed e100 MDI/MDI-X issues").  However,
> careful examination reveals that the attempted revert actually
> _inverted_ the test for eeprom_mdix_enabled.  That is bound to program
> a few PHYs incorrectly...
>
> https://bugzilla.redhat.com/show_bug.cgi?id=1156417
>
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Auke Kok <auke-jan.h.kok@intel.com>
> Cc: Malli Chilakala <mallikarjuna.chilakala@intel.com>
> ---
> Wow, an 8 year old bug in e100 -- woohoo!! :-)
>
> This was causing some serious flakiness for a large cash register
> deployment in Europe.  Testing with this one-line (really,
> one-character) patch seems to have resolved the issue.
>
>  drivers/net/ethernet/intel/e100.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Weird, I did not get this mail.  Anyway, thanks John, I have added
your patch to my queue.
