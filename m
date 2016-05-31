From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 net-next 2/5] bridge: add json support for bridge
 vlan show
Date: Mon, 30 May 2016 19:17:02 -0700
Message-ID: <574CF41E.6020605@cumulusnetworks.com>
References: <1464410236-65044-3-git-send-email-roopa@cumulusnetworks.com> <92ec8efe-8627-2d3a-736d-4fadce3a8bd8@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	anuradhak@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	julien@cumulusnetworks.com
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35806 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162295AbcEaCRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 22:17:05 -0400
Received: by mail-pf0-f181.google.com with SMTP id g64so69385193pfb.2
        for <netdev@vger.kernel.org>; Mon, 30 May 2016 19:17:05 -0700 (PDT)
In-Reply-To: <92ec8efe-8627-2d3a-736d-4fadce3a8bd8@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/29/16, 5:43 PM, Toshiaki Makita wrote:
> On 2016/05/28 13:37, Roopa Prabhu wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> $bridge -c vlan show
>> port	vlan ids
>> swp1	 1 PVID Egress Untagged
>> 	 10-13
>>
>> swp2	 1 PVID Egress Untagged
>> 	 10-13
>>
>> br0	 1 PVID Egress Untagged
>>
>> $bridge -j vlan show
>> {
>>     "swp1": [{
>>             "vlan": 1,
>>             "flags": "PVID Egress Untagged"
> Shouldn't we split flags?

yes, of-course. v2 coming...
