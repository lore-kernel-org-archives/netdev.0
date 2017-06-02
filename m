From: Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>
Subject: Re: [PATCH] b43legacy: Fix a sleep-in-atomic bug in
 b43legacy_attr_interfmode_store
Date: Fri, 02 Jun 2017 09:18:14 +0800
Message-ID: <5930BCD6.9010306@163.com>
References: <1496226547-5921-1-git-send-email-baijiaju1990@163.com>
 <85905124-7167-aeb0-8aff-4ceec09e9542@lwfinger.net>
 <592F6843.9000204@163.com> <20170601101113.6dd30d6d@lwn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
To: Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>
Return-path: <b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20170601101113.6dd30d6d-T1hC0tSOHrs@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/b43-dev/>
List-Post: <mailto:b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "b43-dev" <b43-dev-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

On 06/02/2017 12:11 AM, Jonathan Corbet wrote:
> On Thu, 01 Jun 2017 09:05:07 +0800
> Jia-Ju Bai<baijiaju1990-9Onoh4P/yGk@public.gmane.org>  wrote:
>
>> I admit my patches are not well tested, and they may not well fix the bugs.
>> I am looking forward to opinions and suggestions :)
> May I politely suggest that sending out untested locking changes is a
> dangerous thing to do?  You really should not be changing the locking in a
> piece of kernel code without understanding very well what the lock is
> protecting and being able to say why your changes are safe.  Without that,
> the risk of introducing subtle bugs is very high.
>
> It looks like you have written a useful tool that could help us to make
> the kernel more robust.  If you are interested in my suggestion, I would
> recommend that you post the sleep-in-atomic scenarios that you are
> finding, but refrain from "fixing" them in any case where you cannot offer
> a strong explanation of why your fix is correct.
>
> Thanks for working to find bugs in the kernel!
>
> jon
Hi,

Thanks for your good and helpful advice. I am sorry for my improper patches.
I will only report bugs instead of sending improper patches when I have 
no good solution of fixing the bugs.

Thanks,
Jia-Ju Bai
