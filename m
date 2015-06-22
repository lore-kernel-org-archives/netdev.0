From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC v2 3/3] mpls: support for ip tunnels
Date: Sun, 21 Jun 2015 19:35:25 -0700
Message-ID: <5587746D.7070400@cumulusnetworks.com>
References: <1434689355-4088-4-git-send-email-roopa@cumulusnetworks.com> <20150621202728.GB4228@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, rshearma@brocade.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:32868 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752325AbbFVCfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 22:35:30 -0400
Received: by pdjn11 with SMTP id n11so128615037pdj.0
        for <netdev@vger.kernel.org>; Sun, 21 Jun 2015 19:35:27 -0700 (PDT)
In-Reply-To: <20150621202728.GB4228@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/21/15, 1:27 PM, Thomas Graf wrote:
> On 06/18/15 at 09:49pm, Roopa Prabhu wrote:
>> diff --git a/net/mpls/Kconfig b/net/mpls/Kconfig
>> index 17bde79..3e87a6b 100644
>> --- a/net/mpls/Kconfig
>> +++ b/net/mpls/Kconfig
>> @@ -27,4 +27,9 @@ config MPLS_ROUTING
>>   	help
>>   	 Add support for forwarding of mpls packets.
>>   
>> +config MPLS_IPTUNNEL
>> +	tristate "MPLS: IP over MPLS tunnel support"
>> +	help
>> +	 Light weight tunnel handling for mpls tunnel packets
>> +
> I assume this should select CONFIG_LWTUNNEL
yeah, i will fix this and other few open ends in this area... before the 
next non-RFC round..., thx
