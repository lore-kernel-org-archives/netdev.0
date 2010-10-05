From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: checkentry function
Date: Tue, 5 Oct 2010 14:03:23 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1010051401350.6166@obet.zrqbmnf.qr>
References: <AANLkTimeoRTBMY0OH5sDtVEfqFCx9F3go1qGKy5cJpWS@mail.gmail.com> <20101005144615.0f84d53a@s6510> <AANLkTikDi3ziyH9eJbEhjOBwjFVHrtsMzYEJes4=eiJF@mail.gmail.com> <20101005150147.62226282@s6510> <AANLkTinTd5FjJ-6WeAGwintAS9aHdFYnS7--TLMSDEkn@mail.gmail.com>
 <1286259838.2457.11.camel@edumazet-laptop> <AANLkTinVtz0VuLkOY5d8QjdvLMXOFD2EaWp_kSBbMJBW@mail.gmail.com> <alpine.LNX.2.01.1010051331550.4582@obet.zrqbmnf.qr> <AANLkTim+5kETTN3sbo-woUAEN71woJb1eG9TX04tcyKW@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Nicola Padovano <nicola.padovano@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTim+5kETTN3sbo-woUAEN71woJb1eG9TX04tcyKW@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tuesday 2010-10-05 13:46, Nicola Padovano wrote:
>On Tue, Oct 5, 2010 at 1:32 PM, Jan Engelhardt <jengelh@medozas.de> wrote:
>> On Tuesday 2010-10-05 13:16, Nicola Padovano wrote:
>>>>
>>>> Could you read source code of _current_ existing modules , and use
>>>> copy/paste ?
>>>>
>>>> static int hashlimit_mt_check(const struct xt_mtchk_param *par)
>>>> {
>>>> ...
>>>> }
>>>
>
>this is the whole code:
>
>[WHOLE_CODE]
>static bool xt_function_check(const char *tablename, const void *entry,
>                            const struct xt_target *target, void *targinfo,
>                            unsigned int hook_mask)
>{
>
>  if (strcmp(tablename, "filter"))
>  {
>    printk(KERN_INFO "!=filter %s\n",tablename);
>    return false;
>  }
>
>  return true;
>}

And as Stephen said, the proper type for current kernels
is
(static) bool xt_function_check(const struct xt_mtchk_param *par).

If you are compiling against such, you should have gotten appropriate
warnings from gcc.

