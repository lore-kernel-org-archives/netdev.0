From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH 23/23 V2 for 3.19]  rtlwifi: Fix error when accessing
 unmapped memory in skb
Date: Sun, 28 Dec 2014 00:15:33 -0600
Message-ID: <549FA005.7050802@lwfinger.net>
References: <1419711457-21469-1-git-send-email-Larry.Finger@lwfinger.net> <87a928726w.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Eric Biggers <ebiggers3-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87a928726w.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/27/2014 11:50 PM, Kalle Valo wrote:
> Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> writes:
>
>> These drivers use 9100-byte receive buffers, thus allocating an skb requires
>> an O(3) memory allocation. Under heavy memory loads and fragmentation, such
>> a request can fail. Previous versions of the driver have dropped the packet
>> and reused the old buffer; however, the new version introduced a bug in that
>> it released the old buffer before trying to allocate a new one. The previous
>> method is implemented here.
>>
>> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
>> Cc: Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>  [v3.18]
>> Reported-by: Eric Biggers <ebiggers3-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Cc: Eric Biggers <ebiggers3-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
>>
>> V2 - Fixes an error in the logic of V1. Realtek is working on a change to
>>       the RX buffer allocation, but that is likely to be too invasive for
>>       a fix to -rc or stable. In the meantime, this will help.
>
> 23/23? Where are patches 1-22? I don't see them in patchwork:
>
> https://patchwork.kernel.org/project/linux-wireless/list/

Sorry. I forgot to edit the subject line. To get git to format that one patch, I 
had to generate a total of 23. There is only 1 of 1 that will be submitted.

Larry


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
