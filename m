From: Giri Reddy <giri.reddy@qlogic.com>
Subject: Re: Use of 'SIOCDEVPRIVATE' in ethernet drivers.
Date: Fri, 10 Jan 2014 03:45:32 +0000
Message-ID: <124064C45E1FC84193A69A61ED3A1F46E25237@AVMB1.qlogic.org>
References: <124064C45E1FC84193A69A61ED3A1F46E22D07@AVMB1.qlogic.org>
	 <20140107.140520.1985936966889106257.davem@davemloft.net>
	 <124064C45E1FC84193A69A61ED3A1F46E230D6@AVMB1.qlogic.org>
	 <20140107154456.7e5af377@nehalam.linuxnetplumber.net>
	 <124064C45E1FC84193A69A61ED3A1F46E2331F@AVMB1.qlogic.org>
 <1389301775.2025.43.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:10350 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750702AbaAJDpj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 22:45:39 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/9/14 1:09 PM, Ben Hutchings wrote:
> On Wed, 2014-01-08 at 16:02 +0000, Giri Reddy wrote:
>> Thanks for the input. I will explore the 'ethtool' option. We will have
>> multiple control frames exchanged between user space and kernel for
>> every flash update operation, most of this will be proprietary stuff
>> that will get exchanged - I will explore how to provide a generic
>> interface for that.
> [...]
>
> What you need to do beyond read, write, erase and reset?

Thanks for detailed note about various options for firmware update in
the other email. Aside form the payload we also want control frames
(proprietary) to be exchanged between our firmware and management
application.

Giri

>
> Ben.
>


________________________________

This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.
