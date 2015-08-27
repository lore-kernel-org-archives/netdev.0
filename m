From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH net-next 0/2] Add new switchdev device class
Date: Thu, 27 Aug 2015 01:09:27 -0700
Message-ID: <55DEC5B7.5040505@gmail.com>
References: <1440659806-56582-1-git-send-email-sfeldma@gmail.com> <55DEBDF4.8030301@gmail.com> <20150827074418.GL2228@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, netdev@vger.kernel.org, davem@davemloft.net,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:36302 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751652AbbH0III (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 04:08:08 -0400
Received: by obkg7 with SMTP id g7so9882524obk.3
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 01:08:07 -0700 (PDT)
In-Reply-To: <20150827074418.GL2228@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

>>
>> The structure I used previously which looks like your prototype I think,
>>
>> (https://github.com/jrfastab/rocker-net-next/blob/master/include/uapi/linux/if_flow.h)
>>
>> * [NFL_TABLE_IDENTIFIER_TYPE]
>> * [NFL_TABLE_IDENTIFIER]
>> * [NFL_TABLE_TABLES]
>> *     [NFL_TABLE]
>> *	 [NFL_TABLE_ATTR_NAME]
>> *	 [NFL_TABLE_ATTR_UID]
>> *	 [NFL_TABLE_ATTR_SOURCE]
>> *	 [NFL_TABLE_ATTR_APPLY]
>> *	 [NFL_TABLE_ATTR_SIZE]
>> *	 [NFL_TABLE_ATTR_MATCHES]
>> *	   [NFL_FIELD_REF]
>> *	     [NFL_FIELD_REF_INSTANCE]
>> *	     [NFL_FIELD_REF_HEADER]
>> *	     [NFL_FIELD_REF_FIELD]
>> *	     [NFL_FIELD_REF_MASK]
>> *	     [NFL_FIELD_REF_TYPE]
>> *	   [...]
>> *	 [NFL_TABLE_ATTR_ACTIONS]
>> *	     [NFL_ACTION_ATTR_UID]
>> *	     [...]
>> *     [NFL_TABLE]
>> *       [...]
>> *
>>
>> This is well-typed per Dave's comment. And because its Netlink based it
>> can be easily extended as needed. The above gives basic information on
>> the table. Sure it could stand to have some other entries in it but I
>> never needed them for my capabilities/resource discovery. We could argue
>> about removing some if they are too specific to my use cases.
> 
> I guess you are talking about read-only interface right?
> 

Correct. read-only.
