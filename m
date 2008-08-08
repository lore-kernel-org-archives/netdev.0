From: "John P Poet" <jppoet@gmail.com>
Subject: Re: Realtek 8111C transmit timed out
Date: Thu, 7 Aug 2008 21:28:21 -0600
Message-ID: <2c2a4e250808072028h8b7a13av29ec02f76ab08cd1@mail.gmail.com>
References: <2c2a4e250808041812j569f6565s9f4ae54f44bbfbb5@mail.gmail.com>
	 <2c2a4e250808041900id64a2b8h1b7cee3b70960ebc@mail.gmail.com>
	 <2c2a4e250808042042j6c448068v98a6b5e428fa1a7@mail.gmail.com>
	 <20080805214250.GA23226@electric-eye.fr.zoreil.com>
	 <2c2a4e250808052221p7d22adf5w7a656e423bff0b26@mail.gmail.com>
	 <20080806190353.GB17174@electric-eye.fr.zoreil.com>
	 <2c2a4e250808062251p74f97863l770727843921a5c4@mail.gmail.com>
	 <20080807223137.GA17407@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:28232 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753146AbYHHD2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 23:28:23 -0400
Received: by fg-out-1718.google.com with SMTP id 19so431652fgg.17
        for <netdev@vger.kernel.org>; Thu, 07 Aug 2008 20:28:21 -0700 (PDT)
In-Reply-To: <20080807223137.GA17407@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 7, 2008 at 4:31 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> John P Poet <jppoet@gmail.com> :
> [...]
>> That does not make any difference.
>>
>> I will say, that the problem seems to be reduced by this patch (or the
>> 0002-r8169-avoid-thrashing-PCI-conf-space-above-RTL_GIGA.patch).
>>
>> Before, I was getting failures two or three times an hour.  With
>> either of these patches applied, the failure rate has dropped to one
>> every two to four hours.
>
> I have updated the kit at http://userweb.kernel.org/~romieu/r8169/2.6.27-rc2
>
> Can you give it a try ?

At first I *just* applied 20080807-r8169-test.patch, but the NIC did
not initialize during boot.  So, I also applied
0002-r8169-avoid-thrashing-PCI-conf-space-above-RTL_GIGA.patch.  After
that, it booted okay.

However, in general use it is much worse.  May just be bad luck (or
something in the 2.26.2 kernel?), but the timeout message are rampant:

Aug  7 21:14:58 saphire kernel: NETDEV WATCHDOG: eth0: transmit timed out
Aug  7 21:14:58 saphire kernel: r8169: eth0: link up


John
-- 
A: Because it messes up the order in which people normally read text.
Q: Why is top-posting such a bad thing?
