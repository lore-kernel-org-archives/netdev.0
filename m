From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH] openvswitch: Add packet truncation support.
Date: Thu, 9 Jun 2016 08:57:21 -0700
Message-ID: <575991E1.9020906@hpe.com>
References: <1465435105-21777-1-git-send-email-u9012063@gmail.com>
 <CAOrHB_CNZ2_JCt7RCaMQehZvYxZO-3wL00krbPX-iT1z3iAu=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: pravin shelar <pshelar@ovn.org>, William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t1613g.houston.hpe.com ([15.241.32.99]:44803 "EHLO
	g9t1613g.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168AbcFIP5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 11:57:24 -0400
Received: from g4t3427.houston.hpe.com (g4t3427.houston.hpe.com [15.241.140.73])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by g9t1613g.houston.hpe.com (Postfix) with ESMTPS id 9E99260C23
	for <netdev@vger.kernel.org>; Thu,  9 Jun 2016 15:57:23 +0000 (UTC)
In-Reply-To: <CAOrHB_CNZ2_JCt7RCaMQehZvYxZO-3wL00krbPX-iT1z3iAu=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/08/2016 09:30 PM, pravin shelar wrote:
> On Wed, Jun 8, 2016 at 6:18 PM, William Tu <u9012063@gmail.com> wrote:
>> +struct ovs_action_trunc {
>> +       uint32_t max_len; /* Max packet size in bytes. */
> This could uint16_t. as it is related to packet len.
>

Is there something limiting MTUs to 65535 bytes?

rick jones
