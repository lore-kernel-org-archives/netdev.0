From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [PATCH] checkpatch: See if modified files are marked obsolete in
 MAINTAINERS
Date: Mon, 22 Aug 2016 22:50:15 +0200
Message-ID: <30522d64-8303-cf13-d967-a5759aeb2278@users.sourceforge.net>
References: <87shtwvm63.fsf@kamboji.qca.qualcomm.com>
 <7ceaa510dc9d2df05ec4b456baed7bb1415550b3.1471889575.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Andy Whitcroft <apw@canonical.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Jouni Malinen <j@w1.fi>, kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>,
        linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7ceaa510dc9d2df05ec4b456baed7bb1415550b3.1471889575.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> @@ -2289,6 +2299,10 @@ sub process {
>  		}
>  
>  		if ($found_file) {
> +			if (is_maintained_obsolete($realfile)) {
> +				WARN("OBSOLETE",
> +				     "$realfile is marked as 'obsolete' in the MAINTAINERS hierarchy.  No unnecessary modifications please.\n");
> +			}

How do you think about to avoid a double negation in such a warning message?

Would a wording like "… Only really necessary modifications please.\n"
be more useful here?

Regards,
Markus
