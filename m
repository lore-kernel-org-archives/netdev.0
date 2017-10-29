From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: Re: [patch net-next RFC 1/7] devlink: Add support for resource
 abstraction
Date: Sun, 29 Oct 2017 09:49:39 +0200
Message-ID: <a8589894-e6ee-47c8-af76-4b636dd1edd9@mellanox.com>
References: <20171024092245.1386-1-jiri@resnulli.us>
 <20171024092245.1386-2-jiri@resnulli.us>
 <052995a9-8a84-0690-d32a-e0d53029a858@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        idosch@mellanox.com, jakub.kicinski@netronome.com, ast@kernel.org,
        daniel@iogearbox.net, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, john.hurley@netronome.com,
        alexander.h.duyck@intel.com, linville@tuxdriver.com,
        gospo@broadcom.com, steven.lin1@broadcom.com, yuvalm@mellanox.com,
        ogerlitz@mellanox.com
To: David Ahern <dsa@cumulusnetworks.com>,
        Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr20043.outbound.protection.outlook.com ([40.107.2.43]:63923
        "EHLO EUR02-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750928AbdJ2HuD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 29 Oct 2017 03:50:03 -0400
In-Reply-To: <052995a9-8a84-0690-d32a-e0d53029a858@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/25/2017 06:26 PM, David Ahern wrote:
> On 10/24/17 3:22 AM, Jiri Pirko wrote:
>> diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
>> index 0cbca96..9db1d70 100644
>> --- a/include/uapi/linux/devlink.h
>> +++ b/include/uapi/linux/devlink.h
>> @@ -69,6 +69,8 @@ enum devlink_command {
>>  	DEVLINK_CMD_DPIPE_ENTRIES_GET,
>>  	DEVLINK_CMD_DPIPE_HEADERS_GET,
>>  	DEVLINK_CMD_DPIPE_TABLE_COUNTERS_SET,
>> +	DEVLINK_CMD_RESOURCE_SET,
>> +	DEVLINK_CMD_RESOURCE_DUMP,
>>  
>>  	/* add new commands above here */
>>  	__DEVLINK_CMD_MAX,
>> @@ -201,6 +203,12 @@ enum devlink_attr {
>>  	DEVLINK_ATTR_PAD,
>>  
>>  	DEVLINK_ATTR_ESWITCH_ENCAP_MODE,	/* u8 */
>> +	DEVLINK_ATTR_RESOURCES,			/* nested */
>> +	DEVLINK_ATTR_RESOURCE,			/* nested */
>> +	DEVLINK_ATTR_RESOURCE_NAME,		/* string */
>> +	DEVLINK_ATTR_RESOURCE_SIZE,		/* u64 */
>> +	DEVLINK_ATTR_RESOURCE_SIZE_NEW,		/* u64 */
>> +	DEVLINK_ATTR_RESOURCE_ID,		/* u64 */
>>  
>>  	/* add new attributes above here, update the policy in devlink.c */
>>  
> 
> Where can I find the userspace patch to try out the RFC?
> 

Hi David,

Thanks for the review. I will send the updated version this week
with the userspace part.
