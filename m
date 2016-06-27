From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] rtlwifi: Add missing newlines to RT_TRACE calls
Date: Sun, 26 Jun 2016 20:49:01 -0500
Message-ID: <5770860D.8040607@lwfinger.net>
References: <5677791872bfb47963780c198c825d882456720f.1466969647.git.joe@perches.com>
 <577070D9.5080503@lwfinger.net> <1466990029.1847.74.camel@perches.com>
 <1466990779.1847.78.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1466990779.1847.78.camel-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 06/26/2016 08:26 PM, Joe Perches wrote:
> On Sun, 2016-06-26 at 18:13 -0700, Joe Perches wrote:
>> On Sun, 2016-06-26 at 19:18 -0500, Larry Finger wrote:
>>>
>>> On 06/26/2016 02:34 PM, Joe Perches wrote:
>>>>
>>>>
>>>> RT_TRACE does not add a newline to the end of a message and always
>>>> emits at KERN_DEBUG so these are susceptible to message
>>>> interleaving
>>>> from other processes without the newline.
>>>>
>>>> Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
>>>> ---
>>> This patch does not apply to the wireless-drivers-next repo. Which
>>> one
>>> did you use?
>> linux-next
>
> btw: both patches seem to apply to wireless-drivers-next just fine.
>
> $ git rev-parse HEAD
> 1bb57c8a5e33bcbec031ce0c629968922d5af89d
> $ git am ../next/0001-rtlwifi-Create-_rtl_dbg_trace-function-to-reduce-RT_.patch
> Applying: rtlwifi: Create _rtl_dbg_trace function to reduce RT_TRACE code size
> $ git am ../next/0001-rtlwifi-Add-missing-newlines-to-RT_TRACE-calls.patch
> Applying: rtlwifi: Add missing newlines to RT_TRACE calls

The conflict is with the set of 10 patches I sent out yesterday. As I have to 
update them anyway, I will apply yours first, then do mine. That should resolve 
the problem.

Larry




--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
