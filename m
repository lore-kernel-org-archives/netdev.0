From: Nicola Padovano <nicola.padovano@gmail.com>
Subject: Re: checkentry function
Date: Tue, 5 Oct 2010 13:16:40 +0200
Message-ID: <AANLkTinVtz0VuLkOY5d8QjdvLMXOFD2EaWp_kSBbMJBW@mail.gmail.com>
References: <AANLkTimeoRTBMY0OH5sDtVEfqFCx9F3go1qGKy5cJpWS@mail.gmail.com>
 <20101005144615.0f84d53a@s6510> <AANLkTikDi3ziyH9eJbEhjOBwjFVHrtsMzYEJes4=eiJF@mail.gmail.com>
 <20101005150147.62226282@s6510> <AANLkTinTd5FjJ-6WeAGwintAS9aHdFYnS7--TLMSDEkn@mail.gmail.com>
 <1286259838.2457.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1286259838.2457.11.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>
> Because xxx_check() signature is not the one you use.
>
> Could you read source code of _current_ existing modules , and use
> copy/paste ?
>
> static int hashlimit_mt_check(const struct xt_mtchk_param *par)
> {
> ...
> }

as i've written in a previously mail this is the checkentry function
that i use in my source code to check if the iptables command line is
a right line.

[CHECK_ENTRY_CODE]
static bool xt_tarpit_check(const char *tablename, const void *entry,
                           const struct xt_target *target, void *targinfo,
                           unsigned int hook_mask)
{
 if (strcmp(tablename, "filter"))   {
   printk(KERN_INFO "DEBUG: the tablename (not FILTER) is %s\n",tablename);
   return false;
 }
return true;
}
[/CHECK_ENTRY_CODE]

but it doesn't work...NOTE: the module goes inside the function but
the tablename value is a wrong one (also if I set "-t filter" option
in the iptables command line)

i don't know what "static int hashlimit_mt_check(const struct
xt_mtchk_param *par)" is...

thank you

-- 
Nicola Padovano
e-mail: nicola.padovano@gmail.com
web: http://npadovano.altervista.org

"My only ambition is not be anything at all; it seems the most
sensible thing" (C. Bukowski)
