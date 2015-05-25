From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] staging: r8712u: Fix kernel warning for improper call
 of del_timer_sync()
Date: Mon, 25 May 2015 10:59:43 -0500
Message-ID: <556346EF.8000804@lwfinger.net>
References: <20150525044250.GA3385@sudip-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Arek Rusniak <arek.rusi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: 1432415812-1285-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org,
	haggai.eran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150525044250.GA3385@sudip-PC>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/24/2015 11:42 PM, Sudip Mukherjee wrote:
>> I haven't been using kernel v4.1 so I haven't seen this warning, but looking
>> at the code it seems to originate from the two recent patches to remove
>> _cancel_timer and _cancel_timer_ex. I see that there's another patch in lkml [1]
>> that changes del_timer_sync back to del_timer in more places. Perhaps it
>> could prevent other warnings like this in the future.
>
> _cancel_timer and _cancel_timer_ex both were internally using del_timer,
> and the issue was reported in bugzilla. I have given the reference of the
> bugzilla in my patch in lkml.
> I have changed the reference of del_timer_sync to del_timer in all places
> which were in interrupt context, in some places it was not removed as
> those were not in interrupt context.

Why did you not Cc the maintainers?? That is why file MAINTAINERS exists.

Was your patch sent to Greg?

Larry


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
