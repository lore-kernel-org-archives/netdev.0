From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2 0/2] net: ipv6: Improve user experience with
 multipath routes
Date: Thu, 26 Jan 2017 15:58:21 +0100
Message-ID: <4024f547-7f26-ab52-df9d-a0509048c7ff@6wind.com>
References: <1484892626-14257-1-git-send-email-dsa@cumulusnetworks.com>
 <90d6fdce-7780-b864-0e89-db262dec6fa1@cumulusnetworks.com>
 <20170124.110616.2098461870069191491.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:33685 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752376AbdAZO6Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 09:58:25 -0500
Received: by mail-wm0-f43.google.com with SMTP id d140so5750691wmd.0
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 06:58:24 -0800 (PST)
In-Reply-To: <20170124.110616.2098461870069191491.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/01/2017 à 17:06, David Miller a écrit :
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Fri, 20 Jan 2017 12:31:44 -0700
> 
>> BTW, I am in favor of not requiring a user API for this but just
>> doing it. I can't imagine anyone working with multipath routes not
>> wanting the efficiency of the RTA_MULTIPATH attribute. These patches
>> require an API only because of the rule not to break userspace. If
>> we conclude to just do it without an API, the multipath_add and
>> multipath_del need to be modified to only send a notification once
>> at the end of the actions.
> 
> After some consideration, I agree.
Sorry for my late reply but I fear that this will break some userland apps like
quagga.
I agree that it would be better but the API is here since v3.8, ie 4 years.


Regards,
Nicolas
