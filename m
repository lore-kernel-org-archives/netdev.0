From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 03/21] iplink: bridge: export read-only timers
Date: Mon, 8 Feb 2016 23:26:40 +0100
Message-ID: <56B91620.4030901@cumulusnetworks.com>
References: <1454932527-30569-1-git-send-email-razor@blackwall.org>
 <1454932527-30569-4-git-send-email-razor@blackwall.org>
 <20160208142340.74ec14da@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: Stephen Hemminger <stephen@networkplumber.org>,
	Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:36782 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756530AbcBHW0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 17:26:43 -0500
Received: by mail-wm0-f42.google.com with SMTP id p63so134416506wmp.1
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 14:26:42 -0800 (PST)
In-Reply-To: <20160208142340.74ec14da@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/08/2016 11:23 PM, Stephen Hemminger wrote:
> On Mon,  8 Feb 2016 12:55:09 +0100
> Nikolay Aleksandrov <razor@blackwall.org> wrote:
> 
>> +
>> +	if (tb[IFLA_BR_HELLO_TIMER])
>> +		fprintf(f, "hello_timer %llu ",
>> +			rta_getattr_u64(tb[IFLA_BR_HELLO_TIMER]));
>> +
>> +	if (tb[IFLA_BR_TCN_TIMER])
>> +		fprintf(f, "tcn_timer %llu ",
>> +			rta_getattr_u64(tb[IFLA_BR_TCN_TIMER]));
>> +
>> +	if (tb[IFLA_BR_TOPOLOGY_CHANGE_TIMER])
>> +		fprintf(f, "topology_change_timer %llu ",
>> +			rta_getattr_u64(tb[IFLA_BR_TOPOLOGY_CHANGE_TIMER]));
>> +
>> +	if (tb[IFLA_BR_GC_TIMER])
>> +		fprintf(f, "gc_timer %llu ",
>> +
> 
> These should be rescaled as seconds.
> 

Wanted to be consistent with the other exported time values, but okay
I'll convert these to seconds.

Thanks,
 Nik
