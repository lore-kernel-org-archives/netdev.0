From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: 3.8.4 kernel
Date: Mon, 6 May 2013 18:54:59 -0700
Message-ID: <CAErSpo68AWCGWQHKgoKuD-QFA0b+jbCRf7T_PzzKoUsVwdZHOg@mail.gmail.com>
References: <5153620E.4010608@gmail.com> <CAErSpo6w+tTbwJ7Qinpd0Vx20q5cm2gMvqzE1Do+2=G3b8rcHA@mail.gmail.com>
 <CAErSpo6iwM2r8b-aoiBPjQpkdpcfgLiO+WkpiM1wFsDhxuSXPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Huang, Xiong" <xiong@qca.qualcomm.com>,
	Cloud Ren <cjren@qca.qualcomm.com>,
	netdev <netdev@vger.kernel.org>
To: "Joseph A. Millikan" <josephamillikan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:58908 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759431Ab3EGBzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 21:55:20 -0400
Received: by mail-ob0-f172.google.com with SMTP id xk17so42715obc.3
        for <netdev@vger.kernel.org>; Mon, 06 May 2013 18:55:20 -0700 (PDT)
In-Reply-To: <CAErSpo6iwM2r8b-aoiBPjQpkdpcfgLiO+WkpiM1wFsDhxuSXPg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[+cc Xiong, Cloud, netdev since this looks like an atl1c issue]

On Fri, Apr 26, 2013 at 3:33 PM, Bjorn Helgaas <bhelgaas@google.com> wrote:
> On Wed, Mar 27, 2013 at 3:46 PM, Bjorn Helgaas <bhelgaas@google.com> wrote:
>> On Wed, Mar 27, 2013 at 3:18 PM, Joseph A. Millikan
>> <josephamillikan@gmail.com> wrote:
>>>
>>> We use Mint 11 32-bit and we've noticed with any kernel beyond 3.6.11, the
>>> Ethernet port stops responding to pings after 15 minutes and samba clients
>>> cease to receive data in realtime.  I hope this is the correct place to
>>> report this as we received a nasty, sullen response when posted with the
>>> Ubuntu folks (which we will NEVER do again.)
>>>
>>> If you aren't the proper party to whom we should direct this report, please
>>> disregard.  We were just trying to help developers if there is an
>>> undiscovered issue with Ethernet ports on Lenovo G770 laptops which our
>>> court uses with Mint 11.
>>
>> What specific kernels have you tried?  It'd be surprising if such an
>> egregious issue went unnoticed for long, but if recent kernels like
>> 3.8 or 3.9-rc are still broken, there's likely something we need to
>> fix.  Can you collect complete dmesg logs from 3.6.11 and the oldest
>> broken kernel you've found?  You might also run "watch cat
>> /proc/interrupts" in a window off to the side and see if the NIC
>> interrupt count stops increasing after 15 minutes.
>
> Did this ever get resolved?

I opened https://bugzilla.kernel.org/show_bug.cgi?id=57681 to keep
track of this and attached the dmesg logs you collected.  If you have
a chance, could you also collect and attach the output of "lspci -vv"
(any kernel is fine for this).

I don't see anything obvious wrong, at least from the PCI side.  Maybe
the atl1c guys will have some ideas.

Bjorn
