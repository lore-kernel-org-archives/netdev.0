From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH net 1/1] net: ppp: fix creating PPP pass and active filters
Date: Tue, 15 Jul 2014 10:48:55 +0530
Message-ID: <53C4B9BF.1020902@gmail.com>
References: <53C28297.4080507@kristov.de> <53C29DAA.8020405@gmail.com> <20140713180735.209671xd9qjsgmo7@berry.schulz.ip-v6.eu> <53C2D541.8080900@redhat.com> <20140715065458.15013qglk08wv3mq@kristov.noip.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org,
	paulus@samba.org, isdn@linux-pingi.de
To: Christoph Schulz <develop@kristov.de>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20140715065458.15013qglk08wv3mq@kristov.noip.me>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/15/2014 10:24 AM, Christoph Schulz wrote:
> Hello!
>
> Daniel Borkmann schrieb am Sun, 13 Jul 2014 20:51:45 +0200:
>
>> I think going with the first variant is just fine.
>
> Well, then I need not change anything, do I? This first variant causes 
> checkpatch to warn twice about a line exceeding 80 characters:
>
> WARNING: line over 80 characters
> #83: FILE: drivers/net/ppp/ppp_generic.c:771:
> +                               err = 
> sk_unattached_filter_create(&ppp->pass_filter,
>
> WARNING: line over 80 characters
> #102: FILE: drivers/net/ppp/ppp_generic.c:797:
> +                               err = 
> sk_unattached_filter_create(&ppp->active_filter,
>
> But I don't see how to shorten them. This is because 
> "sk_unattached_filter_create" is such a long identifier...
>
> Any proposals what I can do in order to get the fix accepted?
>
>
There are can be two solutions:

1. Replace the long function name (sk_unattached_filter_create) with the simple macro.
    We can define the macro locally with our driver name.I don't know how many people
    will accept it. For this we have to change the entire filter framework.

2. Shorten the argument name 'pass_filter/active_filter'.
    For this also we need to change the entire framework. People many not be accept it.

-- 
Regards,
Varka Bhadram.

