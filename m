From: Giri Reddy <giri.reddy@qlogic.com>
Subject: Re: Use of 'SIOCDEVPRIVATE' in ethernet drivers.
Date: Wed, 8 Jan 2014 16:02:28 +0000
Message-ID: <124064C45E1FC84193A69A61ED3A1F46E2331F@AVMB1.qlogic.org>
References: <124064C45E1FC84193A69A61ED3A1F46E22D07@AVMB1.qlogic.org>
	<20140107.140520.1985936966889106257.davem@davemloft.net>
	<124064C45E1FC84193A69A61ED3A1F46E230D6@AVMB1.qlogic.org>
 <20140107154456.7e5af377@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:35543 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755363AbaAHQCb convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 11:02:31 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thanks for the input. I will explore the 'ethtool' option. We will have
multiple control frames exchanged between user space and kernel for
every flash update operation, most of this will be proprietary stuff
that will get exchanged - I will explore how to provide a generic
interface for that.

Giri

> Maybe a debugfs or sysfs filesystem would work better than adding ioctl';s

IOCTL option is off the table based on feedback from DaveM. I'm
considering 'sysfs' as an option along with 'ethtool', making this
generic without too much proprietary taint will be the problem that
needs to be solved.

Giri

>


________________________________

This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.
