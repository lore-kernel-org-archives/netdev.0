From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2/net-next] devlink: use DEVLINK_CMD_ESWITCH_*
 instead of DEVLINK_CMD_ESWITCH_MODE_*
Date: Sun, 19 Feb 2017 21:59:06 +0100
Message-ID: <20170219205906.GA1801@nanopsycho>
References: <1487515026-5826-1-git-send-email-jiri@resnulli.us>
 <20170219120115.391906ba@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, mlxsw@mellanox.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34821 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750848AbdBSVAY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 16:00:24 -0500
Received: by mail-wm0-f65.google.com with SMTP id u63so11200168wmu.2
        for <netdev@vger.kernel.org>; Sun, 19 Feb 2017 12:59:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170219120115.391906ba@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Feb 19, 2017 at 09:01:15PM CET, stephen@networkplumber.org wrote:
>On Sun, 19 Feb 2017 15:37:06 +0100
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Sync with kernel and don't use the obsolete enum values.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  devlink/devlink.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>> 
>> diff --git a/devlink/devlink.c b/devlink/devlink.c
>> index 34a409f..c357580 100644
>> --- a/devlink/devlink.c
>> +++ b/devlink/devlink.c
>> @@ -1303,7 +1303,7 @@ static int cmd_dev_eswitch_show(struct dl *dl)
>>  	struct nlmsghdr *nlh;
>>  	int err;
>>  
>> -	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_ESWITCH_MODE_GET,
>> +	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_ESWITCH_GET,
>>  			       NLM_F_REQUEST | NLM_F_ACK);
>>  
>>  	err = dl_argv_parse_put(nlh, dl, DL_OPT_HANDLE, 0);
>> @@ -1321,7 +1321,7 @@ static int cmd_dev_eswitch_set(struct dl *dl)
>>  	struct nlmsghdr *nlh;
>>  	int err;
>>  
>> -	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_ESWITCH_MODE_SET,
>> +	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_ESWITCH_SET,
>>  			       NLM_F_REQUEST | NLM_F_ACK);
>>  
>>  	err = dl_argv_parse_put(nlh, dl, DL_OPT_HANDLE,
>
>I went back and looked at the original commit.
>    devlink: fix the name of eswitch commands
>OK, so you only changed the name, not the value so it would be binary
>compatible.

Yep.

>
>Applied.

Thanks.
