From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [RFD] Network configuration data in sysfs
Date: Mon, 24 Oct 2011 14:46:49 +0200
Message-ID: <CAPXgP10PZU+xSbQW-CH-E5rCk3-=1k-AvAs=tF8fAnz7QsmJRw@mail.gmail.com>
References: <20111024013406.GA24158@shutemov.name> <20111023.232416.1038111296509565828.davem@davemloft.net>
 <20111024042400.GA31344@shutemov.name> <20111024.005900.1091819103500072631.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kirill@shutemov.name, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	gregkh@suse.de, gladkov.alexey@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:40325 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932288Ab1JXMrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 08:47:11 -0400
Received: by ggnb1 with SMTP id b1so5682602ggn.19
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2011 05:47:10 -0700 (PDT)
In-Reply-To: <20111024.005900.1091819103500072631.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 24, 2011 at 06:59, David Miller <davem@davemloft.net> wrote:
> From: "Kirill A. Shutemov" <kirill@shutemov.name>
> Date: Mon, 24 Oct 2011 07:24:00 +0300
>
>> On Sun, Oct 23, 2011 at 11:24:16PM -0400, David Miller wrote:
>>> From: "Kirill A. Shutemov" <kirill@shutemov.name>
>>> Date: Mon, 24 Oct 2011 04:34:07 +0300
>>>
>>> You can use netlink to perform any configuration change you want, or
>>> to view any network configuration setting.
>>
>> You need /sbin/ip or similar tool to do this, right?
>
> I'm talking about udev using netlink natively.

Kirill, what exactly is the use case? And why what does udev support
mean in that context?

I doubt that "not having /sbin/ip installed" should be a reason to add
and expose complex interfaces in /sys, while we already have a
perfectly working native way to do it.

Kay
