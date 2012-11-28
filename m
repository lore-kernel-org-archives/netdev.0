From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH v6 2/6] PM / Runtime: introduce pm_runtime_set_memalloc_noio()
Date: Wed, 28 Nov 2012 12:34:36 +0800
Message-ID: <CACVXFVODD9fRqQc3kR58OJm3ERgBWojnx=790xGwu=MPGaSmMA@mail.gmail.com>
References: <1353761958-12810-1-git-send-email-ming.lei@canonical.com>
	<1353761958-12810-3-git-send-email-ming.lei@canonical.com>
	<5434404.G1ERYjuorE@vostro.rjw.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>,
	Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <5434404.G1ERYjuorE@vostro.rjw.lan>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 28, 2012 at 5:19 AM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
>
> Please use counters instead of walking the whole path every time.  Ie. in
> addition to the flag add a counter to store the number of the device's
> children having that flag set.

Even though counter is added, walking the whole path can't be avoided too,
and may be a explicit walking or recursion, because pm_runtime_set_memalloc_noio
is required to set or clear the flag(or increase/decrease the counter) of
devices in the whole path.

Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
