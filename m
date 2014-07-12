From: Christoph Schulz <develop@kristov.de>
Subject: Re: [PATCH net-next] net: ppp: don't call sk_chk_filter twice
Date: Sat, 12 Jul 2014 23:11:26 +0200
Message-ID: <20140712231126.103531fxfrk9sola@kristov.noip.me>
References: <53BF8DEC.4000307@kristov.de>
 <CAADnVQLQR9fYVGfxfnwpirXt4CwBUzr36tJL+aEoo0err7cppw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8;
 DelSp="Yes";
 format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-ppp@vger.kernel.org, paulus@samba.org, isdn@linux-pingi.de
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <CAADnVQLQR9fYVGfxfnwpirXt4CwBUzr36tJL+aEoo0err7cppw@mail.gmail.com>
Content-Disposition: inline
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

Alexei Starovoitov schrieb am Sat, 12 Jul 2014 05:59:46 +0200:

>> However, sk_chk_filter() is not idempotent as it sometimes replaces filter
>> codes. So running it a second time over the same filter does not work and
>
> It's a good thing not to call sk_chk_filter() twice, but the commit
> log is incorrect.
> sk_chk_filter() doesn't replace filter codes anymore.

Fair enough. Then how should I correctly proceed to submit this patch  
which fixes a bug in the 3.15 branch (only)? In 3.15.x filter codes  
_are_ replaced (I just checked the code in 3.15.5). And I originally  
based my analysis on 3.15.1. Your statement makes the patch an  
optional improvement for 3.16.x, but it's a necessary fix for 3.15.x.  
Do I need to submit this patch two times with different commit logs?


Thank you in advance,

Christoph Schulz

