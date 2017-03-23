From: Greg Ungerer <gerg@linux-m68k.org>
Subject: Re: [PATCH] net: usbnet: support 64bit stats in qmi_wwan driver
Date: Thu, 23 Mar 2017 21:43:41 +1000
Message-ID: <99ed5c61-d7d8-82ac-b026-ea4f8bda7dfc@linux-m68k.org>
References: <1490232332-19274-1-git-send-email-gerg@linux-m68k.org>
 <1490258807.25543.0.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.com>, bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from icp-osb-irony-out1.external.iinet.net.au ([203.59.1.210]:65087
        "EHLO icp-osb-irony-out1.external.iinet.net.au" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932829AbdCWLnp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 07:43:45 -0400
In-Reply-To: <1490258807.25543.0.camel@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Oliver,

On 23/03/17 18:46, Oliver Neukum wrote:
> Am Donnerstag, den 23.03.2017, 11:25 +1000 schrieb Greg Ungerer:
>> Add support for the net stats64 counters to the usbnet core and then to
>> the qmi_wwan driver.
>>
>> This is a strait forward addition of 64bit counters for RX and TX packets
>> and byte counts. It is done in the same style as for the other net drivers
>> that support stats64.
>>
>> The bulk of the change is to the usbnet core. Then it is trivial to use
>> that in the qmi_wwan.c driver. It would be very simple to extend this
>> support to other usbnet based drivers.
>>
>> The motivation to add this is that it is not particularly difficult to
>> get the RX and TX byte counts to wrap on 32bit platforms.
>
> Hi,
>
> you need to export the symbol usbnet_get_stats64
> Other than that it looks good.

Thanks. I will respin a v2 with that fixed.

Regards
Greg
