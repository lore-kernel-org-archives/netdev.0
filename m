From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v2,
 01/10] rt2x00: change function pointers for register accessors
Date: Wed, 24 May 2017 13:46:41 +0000 (UTC)
Message-ID: <20170524134641.96A31611D2@smtp.codeaurora.org>
References: <20170517144702.1381136-2-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Stanislaw Gruszka <sgruszka@redhat.com>,
        David Miller <davem@davemloft.net>,
        Helmut Schaa <helmut.schaa@googlemail.com>,
        Daniel Golle <daniel@makrotopia.org>,
        Mathias Kresin <dev@kresin.me>,
        Johannes Berg <johannes.berg@intel.com>,
        Serge Vasilugin <vasilugin@yandex.ru>,
        Roman Yeryomin <roman@advem.lv>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Jes Sorensen <jes.sorensen@gmail.com>,
        Tom Psyborg <pozega.tomislav@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:46844 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758733AbdEXNqm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 09:46:42 -0400
In-Reply-To: <20170517144702.1381136-2-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann <arnd@arndb.de> wrote:
> This prepares the driver for changing all the 'read' register accessors
> to return the value instead of passing it by reference. Since a lot
> of them are used in callbacks, this takes care of the callbacks first,
> adding a couple of helpers that will be removed again one at a time.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

10 patches applied to wireless-drivers-next.git, thanks.

6b81745e36e3 rt2x00: change function pointers for register accessors
16d571bb0fe6 rt2x00: convert rt2800_rfcsr_read return type
aea8baa10ac5 rt2x00: convert rt2x00_rf_read return type
3954b4e30609 rt2x00: convert rt2x00mmio_register_read return type
48bde9c96972 rt2x00: convert rt2x00usb_register_read return type
eebd68e7824b rt2x00: convert rt2800_register_read return type
5fbbe378890f rt2x00: convert rt2*_bbp_read return type
38651683aa98 rt2x00: convert rt2x00_eeprom_read return type
5c6a25855cbd rt2x00: convert rt2800_eeprom_read return type
b9b238726716 rt2x00: convert rt2x00_desc_read return type

-- 
https://patchwork.kernel.org/patch/9731331/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
