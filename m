From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH iproute2 1/2] utils: add s32 parser
Date: Fri, 25 Nov 2011 12:13:34 +0100
Message-ID: <20111125111333.GA2810@hell>
References: <1322156415-23331-1-git-send-email-hagen@jauu.net>
 <AE90C24D6B3A694183C094C60CF0A2F6D8AEE2@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:46262 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754403Ab1KYLNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 06:13:36 -0500
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AEE2@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Laight | 2011-11-25 09:46:09 [-0000]:

>> +int get_s32(__s32 *val, const char *arg, int base)
>> +{
>> +	long res;
>> +	char *ptr;
>> +
>> +	if (!arg || !*arg)
>> +		return -1;
>
>No need to check *arg, picked up below.

Yes, it is a little bit explicit/duplicate, but I decided to follow all
get_[su][16 32 64] functions to be consistent. If you want you can send a
separate patch afterwards.

HGN
