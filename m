From: Greg Ungerer <gerg@linux-m68k.org>
Subject: Re: [PATCHv3] net: usbnet: support 64bit stats in qmi_wwan driver
Date: Fri, 31 Mar 2017 23:29:51 +1000
Message-ID: <c8c24569-bb07-809d-a8c4-6b5b68852fb3@linux-m68k.org>
References: <1490941561-20502-1-git-send-email-gerg@linux-m68k.org>
 <8737dt25od.fsf@miraculix.mork.no> <1490953150.30466.11.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: eric.dumazet@gmail.com, stephen@networkplumber.org,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.com>,
        =?UTF-8?Q?Bj=c3=b8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from icp-osb-irony-out2.external.iinet.net.au ([203.59.1.155]:37237
        "EHLO icp-osb-irony-out2.external.iinet.net.au" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932986AbdCaN34 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 09:29:56 -0400
In-Reply-To: <1490953150.30466.11.camel@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Oliver,

On 31/03/17 19:39, Oliver Neukum wrote:
> Am Freitag, den 31.03.2017, 10:48 +0200 schrieb Bjørn Mork:
>> You get *all* the "0" line drivers for free, not only "qmi_wwan".  No
>> code changes needed, except for adding the single .ndo line to drivers
>> overriding the usbnet default net_device_ops. And even that only applies
>> to a few of them.  Most will be OK if you just change the usbnet
>> default.
>>
>> I don't think the size of a complete series will be terrifying to
>> anyone.
>
> It would really be nice to do that.
> However, if you really don't want to do it, well you wrote
> a patch. But I am afraid dropping the error count is not acceptable.

Of course dropping error counts would be, but that doesn't happen.

I will generate a patch that converts all usbnet users in one go.

Regards
Greg
