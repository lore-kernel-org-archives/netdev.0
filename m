From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next v2 2/3] net: add trim helper and convert users
Date: Fri, 17 Jan 2014 18:15:49 +0000
Message-ID: <1389982549.27141.15.camel@bwh-desktop.uk.level5networks.com>
References: <1389918519-23779-1-git-send-email-hannes@stressinduktion.org>
	 <1389918519-23779-3-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Daniel Borkmann <dborkman@redhat.com>,
	"Jakub Zawadzki" <darkjames-ws@darkjames.pl>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	<linux-kernel@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389918519-23779-3-git-send-email-hannes@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-01-17 at 01:28 +0100, Hannes Frederic Sowa wrote:
[...]
> --- a/include/linux/kernel.h
> +++ b/include/linux/kernel.h
> @@ -193,6 +193,25 @@ extern int _cond_resched(void);
>  		(__x < 0) ? -__x : __x;		\
>  	})
>  
> +/**
> + * trim - perform a reciprocal multiplication in order to "clamp" a
> + *        value into range [0, ep_ro), where the upper interval
> + *        endpoint is right-open. This is useful, e.g. for accessing
> + *        a index of an array containing ep_ro elements, for example.
> + *        Think of it as sort of modulus, only that the result isn't
> + *        that of modulo. ;)
> + *        More: http://homepage.cs.uiowa.edu/~jones/bcd/divide.html
[...]

And you think trim() is an obvious name for that?!
How about: scale_u32_to_range().

Also the first physical line of a kernel-doc comment (after the name) is
a summary which is used, for example, in the summary line on a manual
page.  It seems like you have the summary and full description the wrong
way round here.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
