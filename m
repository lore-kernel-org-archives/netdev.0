From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH v3 2/6] PM / Runtime: introduce pm_runtime_set[get]_memalloc_noio()
Date: Tue, 30 Oct 2012 19:30:14 +0800
Message-ID: <CACVXFVMTg6k09AWTDZKQCJTBTUGwQ0OoHhdCLFdcbbCv5kzTjw@mail.gmail.com>
References: <1351513440-9286-3-git-send-email-ming.lei@canonical.com>
	<Pine.LNX.4.44L0.1210291125590.22882-100000@netrider.rowland.org>
	<CACVXFVOPDu6wVgPmvtTkokn7VV41x3XVvL4g_E0pz0mikUbvUg@mail.gmail.com>
	<2149424.HsnQpSLjK5@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alan Stern <stern@rowland.harvard.edu>,
	linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-pm@vger.kernel.org, linux-mm@kvack.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <2149424.HsnQpSLjK5@linux-lqwf.site>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Tue, Oct 30, 2012 at 6:57 PM, Oliver Neukum <oneukum@suse.de> wrote:
> how is this to work with power management domains?

Could you explain it in a bit detail? Why is PM domain involved?

Suppose PM domain is involved, its domain runtime_resume callback
is still run in the context with PF_MEMALLOC_NOIO flag set if the
affected 'device' is passed to the callback.

> And I may be dense, but disks are added in slave_configure().
> This seems to be a race to me.

Sorry, could you describe what is the race?

Suppose drivers set correct parent device to the disk device(gendisk),
then add the disk into device model via register_disk(), the solution
should be fine.

Thanks,
--
Ming Lei
