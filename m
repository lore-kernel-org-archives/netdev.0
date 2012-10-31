From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH v3 2/6] PM / Runtime: introduce pm_runtime_set[get]_memalloc_noio()
Date: Thu, 1 Nov 2012 07:18:11 +0800
Message-ID: <CACVXFVM=JTxBc7dUNgAYg3oEveASZMJEvSuTjR+_u0E1ZCUHkA@mail.gmail.com>
References: <Pine.LNX.4.44L0.1210311117310.1954-100000@iolanthe.rowland.org>
	<Pine.LNX.4.44L0.1210311139300.1954-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Oliver Neukum <oneukum@suse.de>, linux-kernel@vger.kernel.org,
	Minchan Kim <minchan@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-pm@vger.kernel.org, linux-mm@kvack.org
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.44L0.1210311139300.1954-100000@iolanthe.rowland.org>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 31, 2012 at 11:41 PM, Alan Stern <stern@rowland.harvard.edu> wrote:
>
> Sorry, I misread your message.  You are setting the device's flag, not
> the thread's flag.

Never mind.

>
> This still doesn't help in this case where CONFIG_PM_RUNTIME is
> disabled.  I think it will be simpler to set the noio flag during every
> device reset.

Yes, it's better to set the flag during every device reset now.

Also pppoe or network interface over serial port is a bit difficult to
deal with, as Oliver pointed out.


Thanks,
--
Ming Lei
