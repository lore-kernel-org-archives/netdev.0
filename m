From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2] iproute2: ipa: show switch id
Date: Thu, 9 Jul 2015 08:09:18 +0200
Message-ID: <20150709060918.GB2270@nanopsycho.orion>
References: <1436368098-21358-1-git-send-email-jiri@resnulli.us>
 <20150708180510.54c90e74@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:33871 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752559AbbGIGJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 02:09:21 -0400
Received: by wifm2 with SMTP id m2so8108672wif.1
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 23:09:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150708180510.54c90e74@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jul 09, 2015 at 03:05:10AM CEST, stephen@networkplumber.org wrote:
>On Wed,  8 Jul 2015 17:08:18 +0200
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>>  
>> +	if (tb[IFLA_PHYS_SWITCH_ID]) {
>> +		SPRINT_BUF(b1);
>> +		fprintf(fp, "switchid %s ",
>> +			hexstring_n2a(RTA_DATA(tb[IFLA_PHYS_SWITCH_ID]),
>> +				      RTA_PAYLOAD(tb[IFLA_PHYS_SWITCH_ID]),
>> +				      b1, sizeof(b1)));
>> +	}
>> +
>
>Ok, but why hex?

What else? It is an arbitrary byte array.
