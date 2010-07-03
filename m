From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: Re: setsockopt(IP_TOS) being privileged or distinct capability?
Date: Sat, 03 Jul 2010 17:07:52 -0600
Message-ID: <4C2FC2C8.8080203@redfish-solutions.com>
References: <4C2F7A55.5090700@redfish-solutions.com> <2md4g7-3s3.ln1@chipmunk.wormnet.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexander Clouter <alex@digriz.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:60739 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755759Ab0GCXIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jul 2010 19:08:00 -0400
In-Reply-To: <2md4g7-3s3.ln1@chipmunk.wormnet.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/3/10 12:55 PM, Alexander Clouter wrote:
> Philip Prindeville<philipp_subx@redfish-solutions.com>  wrote:
>    
>> Does anyone else think that setsockopt(IP_TOS) should be a privileged
>> operation, perhaps using CAP_NET_ADMIN, or maybe even adding separate
>> granularity as CAP_NET_TOS?
>>
>>      
> I really would prefer not having to run telnet and ssh *clients* as
> root. :)
>
> Cheers
>
>    

Don't ping and traceroute -I currently run as root?

