From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 net-next] bridge: mdb: add support for extended
 router port information
Date: Sun, 6 Mar 2016 22:12:56 +0100
Message-ID: <56DC9D58.6000508@cumulusnetworks.com>
References: <1457018374-25420-1-git-send-email-nikolay@cumulusnetworks.com>
 <20160306125604.7978a1d9@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:37797 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798AbcCFVM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 16:12:59 -0500
Received: by mail-wm0-f51.google.com with SMTP id p65so49650398wmp.0
        for <netdev@vger.kernel.org>; Sun, 06 Mar 2016 13:12:59 -0800 (PST)
In-Reply-To: <20160306125604.7978a1d9@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/06/2016 09:56 PM, Stephen Hemminger wrote:
> On Thu,  3 Mar 2016 16:19:34 +0100
> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
> 
>> +static int is_temp_mcast_rtr(__u8 type)
>>  {
>> +	if (type == MDB_RTR_TYPE_TEMP_QUERY || type == MDB_RTR_TYPE_TEMP)
>> +		return 1;
>> +	else
>> +		return 0;
>> +}
>> +
> 
> Minor style issues, why not much simpler:
> 
> static bool is_tmp_mcast_rtr(__u8 type)
> {
> 	return (type == MDB_RTR_TYPE_TEMP_QUERY || type == MDB_RTR_TYPE_TEMP);
> }
> 

Yeah, I considered it but I don't know why I went with
the more explicit one. I'll make a v3 with the change. :-)

Thanks,
 Nik
