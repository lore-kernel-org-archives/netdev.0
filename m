From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Thu, 24 Nov 2016 13:58:34 -0500
Message-ID: <e94d7d6b-2f2f-d10e-8862-ac06bfe69897@pobox.com>
References: <95fa9f67-3af6-6749-0e2b-c95406486f7d@pobox.com>
 <baf5246d-9d8a-4029-6823-350ed561fd33@pobox.com>
 <0835B3720019904CB8F7AA43166CEEB201055ED8@RTITMBSV03.realtek.com.tw>
 <20161124.112152.692025478489876693.davem@davemloft.net>
 <23e0c132-8844-0a34-3e0b-e412f76493ba@pobox.com>
 <20161124184253.GA23483@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hayeswang@realtek.com,
        netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161124184253.GA23483@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-11-24 01:42 PM, Greg KH wrote:
>
> Have you tried using usbmon?

This system is running rootfs over NFS, so usbmon
isn't realistically going to be usable in that scenario
without a lot of reconfiguration of the setup (which in itself
might obscure the original problem).

There is a hardware USB analyzer in the building though.

But it requires a MS-Windows machine (very scarce here, I don't have one)
for the incredibly user-unfriendly software.  I'm not sure if it can be
setup to stop the trace somehow at the right point either, as it takes
overnight runs usually to catch an occurrence of the issue.

I also seem to recall that it only exports data captures in a proprietary
format that only that brand of software/device can read, but perhaps
that might not be true.  Would still need to find a MS-Windows machine/license
to even check it out though.
