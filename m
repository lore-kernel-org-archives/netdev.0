From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net 1/1] net: ppp: fix creating PPP pass and active filters
Date: Sun, 13 Jul 2014 20:51:45 +0200
Message-ID: <53C2D541.8080900@redhat.com>
References: <53C28297.4080507@kristov.de> <53C29DAA.8020405@gmail.com> <20140713180735.209671xd9qjsgmo7@berry.schulz.ip-v6.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Varka Bhadram <varkabhadram@gmail.com>, netdev@vger.kernel.org,
	linux-ppp@vger.kernel.org, paulus@samba.org, isdn@linux-pingi.de
To: Christoph Schulz <develop@kristov.de>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20140713180735.209671xd9qjsgmo7@berry.schulz.ip-v6.eu>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/13/2014 06:07 PM, Christoph Schulz wrote:
> Hello!
>
> Varka Bhadram schrieb am Sun, 13 Jul 2014 20:24:34 +0530:
>
>> checkpatch warnings on this patch
>
> Yes, I know. But could you please give me a hint how to indent this properly such that it doesn't conflict with any formatting rules I possibly don't even know about?
>
> +                        err = sk_unattached_filter_create(&is->pass_filter,
> +                                                          &fprog);

I think going with the first variant is just fine.

> Can I use
>
> +                        err = sk_unattached_filter_create(
> +                                &is->pass_filter, &fprog);
>
> or similar? I do not want to rename variables to fit the line into 80 characteres...
