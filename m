From: Casey Carter <Casey@Carter.net>
Subject: Re: RFC1323. No timestamping if SYN timestamp = 0. Bug or Feature?
Date: Fri, 24 Oct 2003 08:16:13 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F99261D.5030008@Carter.net>
References: <20031022200152.17005.qmail@web13006.mail.yahoo.com> <20031023013748.0dd168db.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bartek Wydrowski <b_wydrowski@yahoo.com.au>, netdev@oss.sgi.com,
        kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031023013748.0dd168db.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

>It is impossible to comply to RFC1323 if we allow TSval in the
>initial SYN packet to be zero, from RFC1323:
>
>         When TSecr is not valid, its value must be zero.
>
>It is therefore impossible to accept TSval as zero, because
>our TSecr echo of that timestamp would be also zero and thus
>invalid.
>
>That is why we reject zero timestamps in the initial SYN packet.
>  
>
Note that the text does not say "When TSecr is zero, it is invalid."  
You are reversing the conditional statement "not valid implies zero" to 
"zero implies not valid." I don't think that the intent of this text in 
the RFC is to forbid the use of zero as a timestamp, but only to assert 
that the value should be set to zero by default.

-- 
Casey Carter
Casey@Carter.net
ccarter@cs.uiuc.edu
AIM: cartec69
