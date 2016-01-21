From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH v3 00/16] add Intel X722 iWARP driver
Date: Thu, 21 Jan 2016 19:05:48 +0200
Message-ID: <56A10FEC.5020402@mellanox.com>
References: <1453318816-21672-1-git-send-email-faisal.latif@intel.com>
 <CAJ3xEMhxMzAVJUNbBHrG8hia2tcFJ4cuPHpq3t9p0FqPHfYX+Q@mail.gmail.com>
 <00cf01d153d5$e6248eb0$b26dac10$@opengridcomputing.com>
 <56A08E8F.7090602@mellanox.com>
 <004401d15460$e77fa1b0$b67ee510$@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: 'Or Gerlitz' <gerlitz.or@gmail.com>,
	'Doug Ledford' <dledford@redhat.com>,
	<linux-rdma@vger.kernel.org>,
	'Linux Netdev List' <netdev@vger.kernel.org>,
	'Jeff Kirsher' <jeffrey.t.kirsher@intel.com>,
	<e1000-rdma@lists.sourceforge.net>
To: Steve Wise <swise@opengridcomputing.com>,
	'Faisal Latif' <faisal.latif@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0070.outbound.protection.outlook.com ([157.56.112.70]:38736
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965302AbcAURF7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jan 2016 12:05:59 -0500
In-Reply-To: <004401d15460$e77fa1b0$b67ee510$@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/21/2016 5:32 PM, Steve Wise wrote:
> Only a single user-space daemon is used.

Good.

> Someone from Intel might have insight into the architecture and design.  Perhaps the intention is that individual drivers might want to have their own handlers for these various operations.  But currently they all use the core/common ones.

But if there's single daemon there and one set of pre-defined  
callbacks, why different netlink commands are needed? in what case the 
damon uses RDMA_NL_NES or RDMA_NL_C4IW or the new define and why?

Or.
