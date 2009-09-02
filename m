From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC][PATCH][v5] net/ethtool: Add support for the ethtool feature
 to flash firmware image from a specified file.
Date: Wed, 02 Sep 2009 12:48:23 -0400
Message-ID: <4A9EA1D7.8090002@pobox.com>
References: <20090821165416.GA17102@serverengines.com> <20090902162241.GB23228@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ajit Khaparde <ajitk@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58798 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751607AbZIBQs1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 12:48:27 -0400
In-Reply-To: <20090902162241.GB23228@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/2009 12:22 PM, Ajit Khaparde wrote:
> On 21/08/09 22:24 +0530, Ajit Khaparde wrote:
>> This patch adds support to flash a firmware image to a device using ethtool.
>> The driver gets the filename of the firmware image and flashes the image
>> using the request firmware path.
>>
>> The region "on the chip" to be flashed can be specified by an option.
>> It is upto the device driver to enumerate the region number passed by ethtool,
>> to the region to be flashed.
>>
>> The default behavior is to flash all the regions on the chip.
> David,
> Is this patch good enough for being accepted? Please let me know if any more
> work has to be done on this.
>
> I want to send the changes to the be2net driver which would use this
> new ethtool feature.  Any ETA for applying the patch to the git tree?
> I will schedule my driver patch according to that.

BTW, don't forget to update the ethtool userland utility as well,
git://git.kernel.org/pub/scm/network/ethtool/ethtool.git

	Jeff



