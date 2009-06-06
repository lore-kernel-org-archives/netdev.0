From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH 1/7] initdev:kernel:Asynchronously-discovered device	synchronization,
 v6
Date: Sat, 06 Jun 2009 10:43:18 +0200
Message-ID: <4A2A2C26.1070106@s5r6.in-berlin.de>
References: <20090606023403.GA5645@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	linux-usb@vger.kernel.org, greg@kroah.com,
	linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	arjan@infradead.org
To: David VomLehn <dvomlehn@cisco.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090606023403.GA5645@cuplxvomd02.corp.sa.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David VomLehn wrote:
> +Some rules about correct usage:
> +o	Each call to initdev_found *must* be matched by a call to
> +	initdev_probe_done.

This would be useful as inline kerneldoc documentation at initdev_found().

> +o	The value of initdev_mask passed to initdev_found and
> +	initdev_probe_done for a given device must be identical.

And this as kerneldoc at initdev_probe_done().

What happens if the calls or the call arguments aren't balanced, e.g. 
due to a mistake in an error path?  The kernel will hang?

(BTW, much, though possibly not all, of the "History" section of your 
changelog should be below the --- delimiter, and the "v6" in the subject 
should be within the [PATCH ...] prefix.)
-- 
Stefan Richter
-=====-==--= -==- --==-
http://arcgraph.de/sr/
