From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 01/21] iplink: bridge: export bridge_id and
 designated_root
Date: Mon, 8 Feb 2016 23:29:42 +0100
Message-ID: <56B916D6.8090408@cumulusnetworks.com>
References: <1454932527-30569-1-git-send-email-razor@blackwall.org>
 <1454932527-30569-2-git-send-email-razor@blackwall.org>
 <20160208142154.35f85b61@xeon-e3> <56B915EF.8000104@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: Stephen Hemminger <stephen@networkplumber.org>,
	Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:34769 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754655AbcBHW3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 17:29:45 -0500
Received: by mail-wm0-f54.google.com with SMTP id 128so174282369wmz.1
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 14:29:45 -0800 (PST)
In-Reply-To: <56B915EF.8000104@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/08/2016 11:25 PM, Nikolay Aleksandrov wrote:
> On 02/08/2016 11:21 PM, Stephen Hemminger wrote:
>> On Mon,  8 Feb 2016 12:55:07 +0100
>> Nikolay Aleksandrov <razor@blackwall.org> wrote:
>>
>>>  
>>> +static void br_dump_bridge_id(const struct ifla_bridge_id *id, char *buf,
>>> +			      size_t len)
>>> +{
>>> +	const unsigned char *x = (const unsigned char *)id;
>>> +
>>> +	snprintf(buf, len, "%.2x%.2x.%.2x%.2x%.2x%.2x%.2x%.2x", x[0], x[1],
>>> +		 x[2], x[3], x[4], x[5], x[6], x[7]);
>>> +}
>>
>> Please don't reinvent ether_ntoa_r
>>
> This was taken from bridge-utils, it actually includes 2 more bytes, it's
> not only an ethernet address.
> 

Also the output is very different, i.e. bridge_id 8000.000000000000
there're no colons.
