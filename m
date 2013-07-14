From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 00/50] USB: cleanup spin_lock in URB->complete()
Date: Sun, 14 Jul 2013 22:33:44 +0800
Message-ID: <CACVXFVPjkUwpnDCeC+y_eczGuen=qu+g74V__SXFCidPp+QYMw@mail.gmail.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
	<1373807844.4998.10.camel@palomino.walls.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	linux-kernel@vger.kernel.org
To: Andy Walls <awalls@md.metrocast.net>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1373807844.4998.10.camel@palomino.walls.org>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 14, 2013 at 9:17 PM, Andy Walls <awalls@md.metrocast.net> wrote:
> On Thu, 2013-07-11 at 17:05 +0800, Ming Lei wrote:
>> Hi,
>>
>> As we are going to run URB->complete() in tasklet context[1][2],
>
> Hi,
>
> Please pardon my naivete, but why was it decided to use tasklets to
> defer work, as opposed to some other deferred work mechanism?
>
> It seems to me that getting rid of tasklets has been an objective for
> years:
>
> http://lwn.net/Articles/239633/
> http://lwn.net/Articles/520076/
> http://lwn.net/Articles/240054/

We discussed the problem in the below link previously[1], Steven
and Thomas suggested to use threaded irq handler, but which
may degrade USB mass storage performance, so we have to
take tasklet now until we rewrite transport part of USB mass storage
driver.

Also the conversion[2] has avoided the tasklet spin lock problem
already.


[1], http://marc.info/?t=137079119200001&r=1&w=2
[2], http://marc.info/?l=linux-usb&m=137286326726326&w=2


Thanks,
--
Ming Lei
