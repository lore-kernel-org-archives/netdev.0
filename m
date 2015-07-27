From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: Re: [PATCH iproute2 net-next] bridge: mdb: add support for router add/del notifications monitoring
Date: Mon, 27 Jul 2015 23:49:38 +0200
Message-ID: <13F15030-8AF3-4018-94B0-F2FF43A4E173@blackwall.org>
References: <1437997445-29541-1-git-send-email-razor@blackwall.org> <20150727144018.1ffb2119@urahara>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:32945 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915AbbG0Vtm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 17:49:42 -0400
Received: by wicmv11 with SMTP id mv11so155988238wic.0
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 14:49:41 -0700 (PDT)
In-Reply-To: <20150727144018.1ffb2119@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On 27 Jul 2015, at 23:40, Stephen Hemminger <stephen@networkplumber.org> wrote:
> 
> On Mon, 27 Jul 2015 13:44:05 +0200
> Nikolay Aleksandrov <razor@blackwall.org> wrote:
> 
>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> 
>> This patch adds support for ADDMDB/DELMDB notifications about router ports
>> which have been added or deleted/expired respectively.
>> 
>> Example output:
>> $ bridge -s monitor mdb
>> Deleted router port dev eth3 master br0
>> router port dev eth3 master br0
>> 
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> Looks useful, applied.
> 
> Does usage or manual page need to be updated as well?
> 
> 

Good question :-) I'll look into it.
Thanks!
