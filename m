From: Ferenc Wagner <wferi@niif.hu>
Subject: Re: [PATCH] vlan: Fix typos in proc output string
Date: Tue, 11 Nov 2008 00:20:17 +0100
Message-ID: <87hc6f5fta.fsf@tac.ki.iif.hu>
References: <877i7hyuf0.fsf@tac.ki.iif.hu>
	<20081110.133802.83808112.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:56545 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750865AbYKJXUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Nov 2008 18:20:20 -0500
In-Reply-To: <20081110.133802.83808112.davem@davemloft.net> (David Miller's
	message of "Mon, 10 Nov 2008 13:38:02 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Ferenc Wagner <wferi@niif.hu>
> Date: Thu, 06 Nov 2008 12:18:27 +0100
>
>> Signed-off-by: Ferenc Wagner <wferi@niif.hu>
>  ...
>> @@ -314,7 +314,7 @@ static int vlandev_seq_show(struct seq_file *seq, void *offset)
>>  		   dev_info->ingress_priority_map[6],
>>  		   dev_info->ingress_priority_map[7]);
>>  
>> -	seq_printf(seq, "EGRESSS priority Mappings: ");
>> +	seq_printf(seq, " EGRESS priority mappings: ");
>>  	for (i = 0; i < 16; i++) {
>>  		const struct vlan_priority_tci_mapping *mp
>>  			= dev_info->egress_priority_map[i];
>
> The typo fix is clearly correct, but adding the leading
> space is not.  Are you simply trying to make the values
> line up with the INGRESS ones on the previous line?

Not as much the values, as those are separated by single spaces on the
egress line but double spaces on the ingress line, except for 6 and 7,
so that is a mess anyway (shall I send another most important patch to
this end?)  But I find the titles easier to parse when their common
parts are lined up.

> Anyways, I'm applying this fix, but I wish you had clarified
> the change as it wasn't totally clear even to me.

Thanks, sorry, and next time I will try to be more explicit.
-- 
Regards,
Feri.
