From: Giri Reddy <giri.reddy@qlogic.com>
Subject: Re: Use of 'SIOCDEVPRIVATE' in ethernet drivers.
Date: Tue, 7 Jan 2014 22:22:45 +0000
Message-ID: <124064C45E1FC84193A69A61ED3A1F46E230D6@AVMB1.qlogic.org>
References: <124064C45E1FC84193A69A61ED3A1F46E22D07@AVMB1.qlogic.org>
 <20140107.140520.1985936966889106257.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:49651 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754139AbaAGWWu convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 17:22:50 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/7/14 11:05 AM, David Miller wrote:
> From: Giri Reddy <giri.reddy@qlogic.com>
> Date: Tue, 7 Jan 2014 18:21:17 +0000
>
>> Are we still allowed to use 'SIOCDEVPRIVATE' in drivers if there the
>> deprecation efforts are on hold.
> To say that use of SIOCDEVPRIVATE is discouraged would be an
> understatement.
>
> Please create a generic ethtool based facility that other drivers in
> similar situations can use as well.

Thanks for the input. I will explore the 'ethtool' option. We will have
multiple control frames exchanged between user space and kernel for
every flash update operation, most of this will be proprietary stuff
that will get exchanged - I will explore how to provide a generic
interface for that.

Giri

>


________________________________

This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.
