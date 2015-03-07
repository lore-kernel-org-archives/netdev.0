From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/3] bond: add support for ndo_switch_port_stp_update
 when bond is a bridge port
Date: Fri, 06 Mar 2015 22:56:48 -0800
Message-ID: <54FAA130.6050800@cumulusnetworks.com>
References: <1425614658-43701-3-git-send-email-roopa@cumulusnetworks.com> <20150306065542.GB2004@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, davem@davemloft.net, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:34968 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752909AbbCGG4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 01:56:50 -0500
Received: by pdbfp1 with SMTP id fp1so29724456pdb.2
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2015 22:56:49 -0800 (PST)
In-Reply-To: <20150306065542.GB2004@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/5/15, 10:55 PM, Jiri Pirko wrote:
> Fri, Mar 06, 2015 at 05:04:17AM CET, roopa@cumulusnetworks.com wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This patch adds support for stp state offload netdev op to support the case
>> where bond is a bridge port and bond slaves are switch ports.
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Maybe the indent should be fixed for the rest to align with
> .ndo_switch_port_stp_update. Not sure if that is needed thought. The
> same note goes for team.
Thanks Jiri. I looked at it and you are right i am not sure i can do 
anything more.
>
> Acked-by: Jiri Pirko <jiri@resnulli.us>
>
>> ---
>> drivers/net/bonding/bond_main.c |    1 +
>> 1 file changed, 1 insertion(+)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 675b082..bf60535 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -4005,6 +4005,7 @@ static const struct net_device_ops bond_netdev_ops = {
>> 	.ndo_fix_features	= bond_fix_features,
>> 	.ndo_bridge_setlink	= ndo_dflt_netdev_switch_port_bridge_setlink,
>> 	.ndo_bridge_dellink	= ndo_dflt_netdev_switch_port_bridge_dellink,
>> +	.ndo_switch_port_stp_update = ndo_dflt_netdev_switch_port_stp_update,
>> };
>>
>> static const struct device_type bond_type = {
>> -- 
>> 1.7.10.4
>>
