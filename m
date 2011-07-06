From: James Henderson <JamesHenderson@ruggedcom.com>
Subject: Re: [Bugme-new] [Bug 38862] New: No support for DGE-530T Rev C1
Date: Wed, 6 Jul 2011 17:48:44 -0400
Message-ID: <4E14D83C.1090506@ruggedcom.com>
References: <bug-38862-10286@https.bugzilla.kernel.org/> <20110706143709.0f5ab7d6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.ruggedcom.com ([204.50.148.11]:53039 "EHLO
	mail2.ruggedcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751729Ab1GFVyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 17:54:11 -0400
In-Reply-To: <20110706143709.0f5ab7d6.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>
> On Wed, 6 Jul 2011 16:05:36 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>
>   
>> https://bugzilla.kernel.org/show_bug.cgi?id=38862
>>
>>            Summary: No support for DGE-530T Rev C1
>>            Product: Drivers
>>            Version: 2.5
>>     Kernel Version: 2.6.39.2
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Network
>>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>>         ReportedBy: jameshenderson@ruggedcom.com
>>         Regression: No
>>
>>
>> The kernel support DGE-530T REV B2 through the skge driver.  The PCI device id
>> of REV-B2 is 1186:4302.  Rev C1 has a PCI device id of 1186:4302.  No driver in
>> the current kernel supports this device id/vendor combination.  Furthermore,
>> this device is not even listed in the device database ->
>> http://www.pcidatabase.com/vendor_details.php?id=921 .
>>
>> On the chip is the following information:
>> D-Link
>> DLG10028C
>> A8A34A1
>> GA50 TAIWAN
>>
>> A sticker on the card reads:
>> DGE-530T Rev C1
>>
>> I am including a picture I took of the card.
>>
>>     
>
> Did you test simply adding that device to the driver?
>
> --- a/drivers/net/skge.c~a
> +++ a/drivers/net/skge.c
> @@ -89,6 +89,7 @@ static DEFINE_PCI_DEVICE_TABLE(skge_id_t
>  	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_YU) },
>  	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, PCI_DEVICE_ID_DLINK_DGE510T) },
>  	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4b01) },	/* DGE-530T */
> +	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK, 0x4302) },	/* DGE-530T Rev C1 */
>  	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4320) },
>  	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x5005) }, /* Belkin */
>  	{ PCI_DEVICE(PCI_VENDOR_ID_CNET, PCI_DEVICE_ID_CNET_GIGACARD) },
> _
>
>   
No I haven't tested that change - I don't have a kernel development 
environment setup and unfortunately I don't have any more work time to 
budget to the issue beyond reporting it.

Also, I meant to say that Rev B2 has PCI id 1186:4B01 (although you seem 
to have figured that out).

Thanks,

James
