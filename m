From: Giri Reddy <giri.reddy@qlogic.com>
Subject: Use of 'SIOCDEVPRIVATE' in ethernet drivers.
Date: Tue, 7 Jan 2014 18:21:17 +0000
Message-ID: <124064C45E1FC84193A69A61ED3A1F46E22D07@AVMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:51873 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752049AbaAGSVU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 13:21:20 -0500
Received: from pps.filterd (m0000643.ppops.net [127.0.0.1])
	by mx0b-0016ce01.pphosted.com (8.14.5/8.14.5) with SMTP id s07IDJVt025463
	for <netdev@vger.kernel.org>; Tue, 7 Jan 2014 10:21:20 -0800
Received: from avcashub1.qlogic.com (avcashub3.qlogic.com [198.70.193.117])
	by mx0b-0016ce01.pphosted.com with ESMTP id 1h8eux8m9k-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 10:21:19 -0800
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm implementing a new interface for upgrading the firmware for our next
generation of Qlogic drivers. We need to transfer control information
between userspace and driver, in addition to the firmware payload. I'm
considering using 'SIOCDEVPRIVATE' ioctl interface to pass control
information between userland and driver.

I also see comments in the source (include/linux/sockios.h) that
'SIOCDEVPRIVATE' will be deprecated 2.5.x. What is the current status of
deprecation in the latest versions of the kernel?

Are we still allowed to use 'SIOCDEVPRIVATE' in drivers if there the
deprecation efforts are on hold.

Any input will be appreciated.

Thanks.
Giri
Qlogic

________________________________

This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.
