From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH iproute2] bridge link: add option 'self'
Date: Fri, 5 Dec 2014 08:55:59 +0100
Message-ID: <20141205075559.GC1866@nanopsycho.orion>
References: <1417746436-41023-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, jhs@mojatatu.com, bcrl@kvack.org, tgraf@suug.ch,
	john.fastabend@gmail.com, stephen@networkplumber.org,
	linville@tuxdriver.com, nhorman@tuxdriver.com,
	nicolas.dichtel@6wind.com, vyasevic@redhat.com,
	f.fainelli@gmail.com, buytenh@wantstofly.org, aviadr@mellanox.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:63854 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbaLEH4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 02:56:01 -0500
Received: by mail-wi0-f180.google.com with SMTP id n3so493850wiv.13
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 23:56:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1417746436-41023-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Dec 05, 2014 at 03:27:16AM CET, roopa@cumulusnetworks.com wrote:
>From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
>Currently self is set internally only if hwmode is set.
>This makes it necessary for the hw to have a mode.
>There is no hwmode really required to go to hardware. So, introduce
>self for anybody who wants to target hardware.


Signed-off line is missing.

Other than that, the patch looks fine.

Reviewed-by: Jiri Pirko <jiri@resnulli.us>

Feel free to add my review line to the repost.


>---
> bridge/link.c |    3 +++
> 1 file changed, 3 insertions(+)
>
>diff --git a/bridge/link.c b/bridge/link.c
>index 90d9e7f..2b86141 100644
>--- a/bridge/link.c
>+++ b/bridge/link.c
>@@ -321,6 +321,9 @@ static int brlink_modify(int argc, char **argv)
> 					"\"veb\".\n");
> 				exit(-1);
> 			}
>+		} else if (strcmp(*argv, "self") == 0) {
>+			NEXT_ARG();
>+			flags = BRIDGE_FLAGS_SELF;
> 		} else {
> 			usage();
> 		}
>-- 
>1.7.10.4
>
