From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/5] net: rfkill: add rfkill_find_type function
Date: Thu, 6 Aug 2015 14:31:31 +0300
Message-ID: <55C34593.8010907@cogentembedded.com>
References: <1438781947-7952-1-git-send-email-heikki.krogerus@linux.intel.com>
 <1438781947-7952-3-git-send-email-heikki.krogerus@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Mika Westerberg <mika.westerberg@linux.intel.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org
To: Heikki Krogerus <heikki.krogerus@linux.intel.com>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438781947-7952-3-git-send-email-heikki.krogerus@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 8/5/2015 4:39 PM, Heikki Krogerus wrote:

> Helper for finding the type based on name. Useful if the
> type needs to be determined based on device property.

> Signed-off-by: Heikki Krogerus <heikki.krogerus@linux.intel.com>
> ---
>   include/linux/rfkill.h | 15 +++++++++++++
>   net/rfkill/core.c      | 57 +++++++++++++++++++++++++-------------------------
>   2 files changed, 44 insertions(+), 28 deletions(-)

> diff --git a/include/linux/rfkill.h b/include/linux/rfkill.h
> index d901078..02f563c 100644
> --- a/include/linux/rfkill.h
> +++ b/include/linux/rfkill.h
[...]
> @@ -268,6 +277,12 @@ static inline bool rfkill_blocked(struct rfkill *rfkill)
>   {
>   	return false;
>   }
> +
> +static inline enum rfkill_type rfkill_find_type(const char *name)
> +{
> +	return 0;
 > +}
 > +

    Shouldn't it return some member of 'enum rfkill_type' instead?

[...]

MBR, Sergei
