From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: add vlan id to mdb notifications
Date: Wed, 26 Nov 2014 14:40:35 -0500
Message-ID: <54762CB3.4090101@cumulusnetworks.com>
References: <1417010013-31454-1-git-send-email-roopa@cumulusnetworks.com> <20141126105614.6a42d697@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, netdev@vger.kernel.org,
	wkok@cumulusnetworks.com, gospo@cumulusnetworks.com,
	sashok@cumulusnetworks.com
To: Stephen Hemminger <stephen@networkplumber.org>,
	roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:56289 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750792AbaKZTkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 14:40:39 -0500
In-Reply-To: <20141126105614.6a42d697@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/14 1:56 PM, Stephen Hemminger wrote:
> On Wed, 26 Nov 2014 05:53:33 -0800
> roopa@cumulusnetworks.com wrote:
>
>> diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
>> index da17e45..db061fd 100644
>> --- a/include/uapi/linux/if_bridge.h
>> +++ b/include/uapi/linux/if_bridge.h
>> @@ -185,6 +185,7 @@ struct br_mdb_entry {
>>   			struct in6_addr ip6;
>>   		} u;
>>   		__be16		proto;
>> +		__be16		vid;
>>   	} addr;
>>   };
>>
>
> You can't add fields to existing binary API
>

Roopa, maybe a description of what use case this is trying to solve 
would better justify the addition to the UAPI?

-Jon
