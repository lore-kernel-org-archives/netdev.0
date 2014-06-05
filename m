From: Jes Sorensen <Jes.Sorensen@redhat.com>
Subject: Re: [PATCH] rtlwifi: Add firmware for r8723au
Date: Thu, 05 Jun 2014 08:43:12 +0200
Message-ID: <wrfjfvjjn9fj.fsf@ultrasam.lan.trained-monkey.org>
References: <1388709729-28496-1-git-send-email-Larry.Finger@lwfinger.net>
	<1390174519.3651.3.camel@deadeye.wl.decadent.org.uk>
	<1401833651.2412.35.camel@deadeye.wl.decadent.org.uk>
	<538F4540.9080002@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ben Hutchings <ben@decadent.org.uk>, dwmw2@infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26462 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750715AbaFEGnq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2014 02:43:46 -0400
In-Reply-To: <538F4540.9080002@lwfinger.net> (Larry Finger's message of "Wed,
	04 Jun 2014 11:11:44 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Larry Finger <Larry.Finger@lwfinger.net> writes:
> On 06/03/2014 05:14 PM, Ben Hutchings wrote:
>> On Sun, 2014-01-19 at 23:35 +0000, Ben Hutchings wrote:
>>> On Thu, 2014-01-02 at 18:42 -0600, Larry Finger wrote:
>>>> This firmware is for a driver that will soon be submitted to the kernel.
>>>> It occurs as data statements in Realtek driver
>>>> rtl8723A_WiFi_linux_v4.1.3_6044.20121224.
>>>>
>>>> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
>>>> ---
>>>>   WHENCE                         |  13 +++++++++++++
>>>>   rtlwifi/rtl8723aufw_A.bin      | Bin 0 -> 22172 bytes
>>>>   rtlwifi/rtl8723aufw_B.bin      | Bin 0 -> 24118 bytes
>>>>   rtlwifi/rtl8723aufw_B_NoBT.bin | Bin 0 -> 19200 bytes
>>>>   4 files changed, 13 insertions(+)
>>>>   create mode 100644 rtlwifi/rtl8723aufw_A.bin
>>>>   create mode 100644 rtlwifi/rtl8723aufw_B.bin
>>>>   create mode 100644 rtlwifi/rtl8723aufw_B_NoBT.bin
>>> [...]
>>>
>>> Applied, thanks.
>>
>> I just noticed that the driver in Linux 3.15 seems to ask for
>> rtlwifi/rtl8723aufw.bin and not rtlwifi/rtl8723aufw_A.bin.  You'll need
>> to change the filename on one side or the other.
>
> Jes,
>
> As Ben points out, I messed up the firmware names, and one of them
> needs to be changed. Keeping the name "rtlwifi/rtl8723aufw_A.bin"
> would retain a certain amount of symmetry, but is may be easier to
> retain "rtlwifi/rtl8723aufw.bin" in the code. A third option would be
> to try for one of the names and fall back to the other if it
> fails. What do you think?
>
> In any case, we need additional MODULE_FIRMWARE macros for the other
> two firmware files.

I'd opt for keeping the _A filename in place. It's for the rev A chip,
and I haven't had any complaints for the current code failing due to the
naming, so unlikely that a lot of people are trying to use it.

I'll change the name in the code here and submit it with my next
changeset. I'll add the MODULE_FIRMWARE bits with it.

Cheers,
Jes
