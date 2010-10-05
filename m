From: Nicola Padovano <nicola.padovano@gmail.com>
Subject: Re: checkentry function
Date: Tue, 5 Oct 2010 08:11:09 +0200
Message-ID: <AANLkTinTd5FjJ-6WeAGwintAS9aHdFYnS7--TLMSDEkn@mail.gmail.com>
References: <AANLkTimeoRTBMY0OH5sDtVEfqFCx9F3go1qGKy5cJpWS@mail.gmail.com>
 <20101005144615.0f84d53a@s6510> <AANLkTikDi3ziyH9eJbEhjOBwjFVHrtsMzYEJes4=eiJF@mail.gmail.com>
 <20101005150147.62226282@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101005150147.62226282@s6510>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>
> Negative (ie < 0) is used for error numbers. This is confusing
> because in older kernels the checkentry returned a bool which
> is defined as 1 okay and 0 for error.
>
ok i see.

and why i have this output?
DEBUG: the tablename (not FILTER) is: =EF=BF=BD%H =EF=BF=BD

I want block my target if the table name is NOT filter...so i write:

[CODE]
=2E..
 if (strcmp(tablename, "filter"))   {
   printk(KERN_INFO "DEBUG: the tablename (not FILTER) is %s\n",tablena=
me);
   return ERROR_VALUE; // < 0
 }
[/CODE]

but in the tablename variable i haven't the table's right value (but i
have: =EF=BF=BD%H =EF=BF=BD a wrong value)...what's the problem?


--=20
Nicola Padovano
e-mail: nicola.padovano@gmail.com
web: http://npadovano.altervista.org

"My only ambition is not be anything at all; it seems the most
sensible thing" (C. Bukowski)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
