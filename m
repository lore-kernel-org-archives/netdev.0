From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 0/2] USBNET: max rx/tx qlen change
Date: Thu, 25 Jul 2013 22:19:17 +0800
Message-ID: <CACVXFVO5XCY2i+QhHL500TqDp7DiLEyvgUvDWxVpMRwd+pt3VA@mail.gmail.com>
References: <1374731274-27415-1-git-send-email-ming.lei@canonical.com>
	<1374737903.4060.15.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:46797 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755576Ab3GYOTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 10:19:20 -0400
In-Reply-To: <1374737903.4060.15.camel@linux-fkkt.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, Jul 25, 2013 at 3:38 PM, Oliver Neukum <oneukum@suse.de> wrote:
> On Thu, 2013-07-25 at 13:47 +0800, Ming Lei wrote:
>> Hi,
>>
>> There are two patches on computing max rx/tx qlen, and fix one
>> performance problem on USB3 NIC.
>
> I am afraid bisectability on SS is impaired. Otherwise
> this looks good.

Bisectability on SS can't be impaired, and it is always the 2nd
patch which fixes the performance issue on SS, and the 1st one
only does code refactoring thing.


Thanks,
--
Ming Lei
