From: Jarl Friis <jarl-bE7lSbLpGj1/SzgSGea1oA@public.gmane.org>
Subject: Re: [PATCH 1/2] Added information about which firmware file is being
 requested.
Date: Wed, 19 Sep 2012 20:56:22 +0200
Message-ID: <CAOjsGA3BgzBn-YOEFYFs5HqLAh4_d46Juj1M-XYooqXeVtn9uw@mail.gmail.com>
References: <1348053493-22955-1-git-send-email-jarl@softace.dk>
 <505A1206.4020606@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Michael Tokarev <mjt-XAri/EZa3C4vJsYlp49lxw@public.gmane.org>
Return-path: <b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <505A1206.4020606-Gdu+ltImwkhes2APU0mLOQ@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/b43-dev/>
List-Post: <mailto:b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b43-dev-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Errors-To: b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

2012/9/19 Michael Tokarev <mjt-XAri/EZa3C4vJsYlp49lxw@public.gmane.org>:
> On 19.09.2012 15:18, Jarl Friis wrote:
>
>> +     b43info(ctx->dev->wl, "Requesting firmware file '%s'\n", ctx->fwname);
>>       err = request_firmware(&blob, ctx->fwname, ctx->dev->dev->dev);
>
> Hmm.  I wonder if this should be printed in request_firmware()
> itself instead of in all callers?

Now that you mention it, I also think that is a much better idea.
However that would be a much more central place to do the change, so I
would gladly see somebody else do that patch (in replacement of mine)

Jarl
