From: Haiyang Zhang <haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>
Subject: RE: [PATCH 02/14 v2] usb/net: rndis: break out <linux/rndis.h>
 defines
Date: Thu, 26 Apr 2012 13:00:54 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC0DD3713E@TK5EX14MBXC221.redmond.corp.microsoft.com>
References: <1335367808-4254-1-git-send-email-linus.walleij@linaro.org>
	<A1F3067C9B68744AA19F6802BAB8FFDC0DD36CAE@TK5EX14MBXC221.redmond.corp.microsoft.com>,<20120425.194545.1399301965144213487.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org" <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"balbi-l0cyMroinI0@public.gmane.org" <balbi-l0cyMroinI0@public.gmane.org>,
	"jussi.kivilinna-E01nCVcF24I@public.gmane.org" <jussi.kivilinna-E01nCVcF24I@public.gmane.org>,
	"yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org" <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>,
	"ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org" <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120425.194545.1399301965144213487.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

________________________________________
> From: David Miller [davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org]
> Sent: Wednesday, April 25, 2012 7:45 PM
> To: Haiyang Zhang
> Cc: linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org; balbi-l0cyMroinI0@public.gmane.org; jussi.kivilinna-E01nCVcF24I@public.gmane.org; yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org; ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org
> Subject: Re: [PATCH 02/14 v2] usb/net: rndis: break out <linux/rndis.h> defines
> 
> From: Haiyang Zhang <haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>
> Date: Wed, 25 Apr 2012 20:38:31 +0000
> 
> > Reviewed-by: Haiyang Zhang <haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>
> 
> I don't think you really thoroughly reviewed this patch, otherwise
> you would have noticed the duplicate definitions that result from
> this patch which adds hundreds of warnings to the build.

Actually, I did see the duplicate defines, I also noticed the author pointing out
-- "The compilation screams about double-defines all over the place." In my
test, the warnings go away after all patches applied.

But, thanks for your comments. I believe the author has now realized that
consolidating the defines and removing the duplicates should be done in one
patch so that there are no warnings.

Thanks,
- Haiyang
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
