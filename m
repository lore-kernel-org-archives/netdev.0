From: Sean Hefty <mshefty@ichips.intel.com>
Subject: Re: [ofa-general] Re: [PATCH v2] iw_cxgb3: Support "iwarp-only" interfaces
 to avoid 4-tuple conflicts.
Date: Mon, 17 Sep 2007 09:09:06 -0700
Message-ID: <46EEA6A2.2080001@ichips.intel.com>
References: <20070913191617.30937.95960.stgit@dell3.ogc.int>	<20070914130941.GG18517@2ka.mipt.ru> <46EC00BE.3020801@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	rdreier@cisco.com, general@lists.openfabrics.org,
	linux-kernel@vger.kernel.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:20307 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752399AbXIQQJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 12:09:10 -0400
In-Reply-To: <46EC00BE.3020801@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> +    addr = kmalloc(sizeof *addr, GFP_KERNEL);
>>
>> As a small nitpick: this wants to be sizeof(struct in_ifaddr)

See chapter 14 of CodingStyle document.  kmalloc(sizeof *addr... is correct.

- Sean
