From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 3/3 3.18] rtlwifi: rtl8192se: Fix connection problems
Date: Thu, 06 Nov 2014 16:46:42 -0600
Message-ID: <545BFA52.6000309@lwfinger.net>
References: <1415236254-12274-1-git-send-email-Larry.Finger@lwfinger.net> <1415236254-12274-4-git-send-email-Larry.Finger@lwfinger.net> <20141106204549.GD4440@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:53292 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660AbaKFWqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 17:46:44 -0500
In-Reply-To: <20141106204549.GD4440@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/06/2014 02:45 PM, John W. Linville wrote:
> On Wed, Nov 05, 2014 at 07:10:54PM -0600, Larry Finger wrote:
>> Changes in the vendor driver were added to rtlwifi, but some updates
>> to rtl8192se were missed.
>>
>> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
>> ---
>>   drivers/net/wireless/rtlwifi/rtl8192se/hw.c  | 129 +++++++++++++--------------
>>   drivers/net/wireless/rtlwifi/rtl8192se/phy.c |   8 +-
>>   drivers/net/wireless/rtlwifi/rtl8192se/sw.c  |   4 +
>>   drivers/net/wireless/rtlwifi/rtl8192se/trx.c |  23 +++++
>>   drivers/net/wireless/rtlwifi/rtl8192se/trx.h |   4 +
>>   5 files changed, 100 insertions(+), 68 deletions(-)
>
> This looks a bit big for a fix.  Could this be broken-up a bit more?
> Perhaps you could enhance the changelog a bit more?

I had used a scatter-gun approach to finding the missing parts, and I did not 
take the time to see which changes were crucial, and which were not.

Now that I knew what it took, I was able to eliminate a lot of the patch that 
can be deferred for 3.19.

The commit message and the changelog for the new version are

Changes in the vendor driver were added to rtlwifi, but some updates
to rtl8192se were missed, and the driver could neither scan nor connect.
There are other changes that will enhance performance, but this minimal
set fixes the basic functionality.

  drivers/net/wireless/rtlwifi/pci.c           |  3 ++-
  drivers/net/wireless/rtlwifi/rtl8192se/hw.c  |  7 +++++--
  drivers/net/wireless/rtlwifi/rtl8192se/phy.c |  2 ++
  drivers/net/wireless/rtlwifi/rtl8192se/sw.c  | 16 ++++++++++++++++
  4 files changed, 25 insertions(+), 3 deletions(-)

Will that be OK? I need to do more testing, but V2 of the patch should be ready 
for submission by tomorrow.

Thanks,

Larry
