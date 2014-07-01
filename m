From: Kees Cook <keescook@chromium.org>
Subject: Re: [RESEND][PATCH] rtlwifi: btcoexist: avoid format string in printk
Date: Tue, 1 Jul 2014 11:31:28 -0700
Message-ID: <CAGXu5jKKav6Nq3AL=oup9SWrgHTvLM9L8f2-AYo6vQr3hFyXtA@mail.gmail.com>
References: <20140630203849.GA4787@www.outflux.net>
	<20140701182908.GD6358@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-wireless@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140701182908.GD6358@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 1, 2014 at 11:29 AM, John W. Linville
<linville@tuxdriver.com> wrote:
> Please look in the git trees before reposting patches...
>
> commit 6437f51ec36af8ef1e3e2659439b35c37e5498e2
> Author: Kees Cook <keescook@chromium.org>
> Date:   Tue Jun 10 10:37:24 2014 -0700
>
>     rtlwifi: btcoexist: avoid format string in printk
>
>     Since CL_PRINTF only ever takes a single argument, make sure a format
>     string cannot leak into printk.
>
>     Signed-off-by: Kees Cook <keescook@chromium.org>
>     Signed-off-by: John W. Linville <linville@tuxdriver.com>

Ah! Thanks very much. I hadn't gotten any email about it getting
applied, so I incorrectly assumed it hadn't been. :)

-Kees

>
> On Mon, Jun 30, 2014 at 01:38:49PM -0700, Kees Cook wrote:
>> Since CL_PRINTF only ever takes a single argument, make sure a format
>> string cannot leak into printk.
>>
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>> ---
>>  .../net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h  |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h
>> index 871fc3c6d559..049f4c8d98a8 100644
>> --- a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h
>> +++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h
>> @@ -114,7 +114,7 @@ extern u32 btc_dbg_type[];
>>
>>
>>  #define      CL_SPRINTF      snprintf
>> -#define      CL_PRINTF       printk
>> +#define      CL_PRINTF(buf)  printk("%s", buf)
>>
>>  #define      BTC_PRINT(dbgtype, dbgflag, printstr, ...)              \
>>       do {                                                    \
>> --
>> 1.7.9.5
>>
>>
>> --
>> Kees Cook
>> Chrome OS Security
>>
>
> --
> John W. Linville                Someday the world will need a hero, and you
> linville@tuxdriver.com                  might be all we have.  Be ready.



-- 
Kees Cook
Chrome OS Security
