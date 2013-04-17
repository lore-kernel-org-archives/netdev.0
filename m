From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH 12/14] netlink: add documentation for memory mapped I/O
Date: Wed, 17 Apr 2013 20:56:41 +0200
Message-ID: <516EF069.6000706@redhat.com>
References: <1366217229-22705-1-git-send-email-kaber@trash.net> <1366217229-22705-13-git-send-email-kaber@trash.net> <516EE10D.2080608@redhat.com> <1e17db69-0d5c-40dc-81ac-2904aab008c3@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10657 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966517Ab3DQS4t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Apr 2013 14:56:49 -0400
In-Reply-To: <1e17db69-0d5c-40dc-81ac-2904aab008c3@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/17/2013 08:08 PM, Patrick McHardy wrote:
> Daniel Borkmann <dborkman@redhat.com> schrieb:
>> On 04/17/2013 06:47 PM, Patrick McHardy wrote:
>>> Signed-off-by: Patrick McHardy <kaber@trash.net>
>>> ---
>> [...]
>>> +Ring frames
>>> +------------
>>> +
>>> +Each frames contain a frame header, consisting of a synchronization
>> word and some
>>> +meta-data, and the message itself.
>>> +
>>> +Frame:	[ header message ]
>>> +
>>> +The frame header is defined as follows:
>>> +
>>> +struct nl_mmap_hdr {
>>> +	unsigned int	nm_status;
>>> +	unsigned int	nm_len;
>>> +	__u32		nm_group;
>>> +	/* credentials */
>>> +	__u32		nm_pid;
>>> +	__u32		nm_uid;
>>> +	__u32		nm_gid;
>>> +};
>>
>> Hm, just wondering, maybe it could be a safer path to make 'nm_status'
>> and 'nm_len' also of fixed width as the rest of nl_mmap_hdr, and as in
>> PF_PACKET's tpacket2_hdr and tpacket3_hdr ?
>> --
>> To unsubscribe from this list: send the line "unsubscribe
>> netfilter-devel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> The size of int is not going to change, but I agree that it is cleaner. I'll send a patch to change this once/if this is merged.

Sounds great, thanks !
