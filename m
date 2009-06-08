From: David VomLehn <dvomlehn@cisco.com>
Subject: Re: [PATCH 3/7] initdev:kernel:Await console discovery, v6
Date: Mon, 8 Jun 2009 15:34:06 -0700
Message-ID: <20090608223406.GD22222@cuplxvomd02.corp.sa.net>
References: <20090606023407.GA5695@cuplxvomd02.corp.sa.net> <4A2A2EED.3060506@s5r6.in-berlin.de> <20090608221344.GB22222@cuplxvomd02.corp.sa.net> <4A2D90EB.4070005@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	linux-usb@vger.kernel.org, greg@kroah.com,
	linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	arjan@infradead.org
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A2D90EB.4070005@s5r6.in-berlin.de>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 09, 2009 at 12:30:03AM +0200, Stefan Richter wrote:
> David VomLehn wrote:
>> On Sat, Jun 06, 2009 at 04:55:09AM -0400, Stefan Richter wrote:
>>> David VomLehn wrote:
> ...
>>>> v3.2	Use only a single new command line parameter by adding the possible
>>>> 	value "forever".  Add message specifying the parameter to modify to
>>>> 	increase the delay for console initialization
>>>> v3.1	Correct the abbreviation for milliseconds in
>>>> 	Documentation/kernel-parameters.txt to be "ms", not "mS". Thanks to
> ...
>>>> ---
>>>>  drivers/accessibility/braille/braille_console.c |    2 +
>>>>  kernel/printk.c                                 |   29 ++++++++++++++++++++++-
>>>>  2 files changed, 30 insertions(+), 1 deletions(-)
>>> Is this diff complete?
>>
>> To the best of my knowledge, yes, it is complete. What makes it look as though
>> it might not be?
>
> The history notes.
> kernel-parameters.txt, new command line parameter...

Now I understand--you haven't been following this in detail, and there is
no reason why you should have. The history reflects the fact that the
original approach changed completely once Alan Stern let me know that we
really could tell when we have discovered all attached USB devices. It's
still trying to solve the same problem, however, so I kept the history
for continuity.

> Stefan Richter
