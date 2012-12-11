From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH][RFC] smsc95xx: enable dynamic autosuspend (RFC)
Date: Tue, 11 Dec 2012 16:19:34 +0100
Message-ID: <3108632.YdjKGB5H1R@linux-lqwf.site>
References: <1353607526-19307-6-git-send-email-steve.glendinning@shawell.net> <1881907.JmjSTg2PBW@linux-lqwf.site> <CACVXFVMNshNMJ+hYHTCfE2+UOuMgGLb0dKq8qEM-LfUseuy2qA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Steve Glendinning <steve@shawell.net>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:60622 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753833Ab2LKPTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 10:19:11 -0500
In-Reply-To: <CACVXFVMNshNMJ+hYHTCfE2+UOuMgGLb0dKq8qEM-LfUseuy2qA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 11 December 2012 20:53:19 Ming Lei wrote:
> In fact, I have test data which can show a much power save
> on OMAP3 based beagle board plus asix usbnet device with
> the periodic work. IMO, the power save after introducing periodic
> timer depends on the arch or platform, there should be much power
> save if the CPU power consumption is very less. So how about letting
> module parameter switch on/off the periodic work?

You could ask on linux-power and netdev. But there would be an
obvious question: Why kernel space?

	Regards
		Oliver
