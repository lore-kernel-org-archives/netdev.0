From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH][RFC] smsc95xx: enable dynamic autosuspend (RFC)
Date: Tue, 11 Dec 2012 23:58:19 +0800
Message-ID: <CACVXFVMN85g2+B_-1kyTJ=kSDWD5vbSja-hjTHvy2dLk1YN6cw@mail.gmail.com>
References: <1353607526-19307-6-git-send-email-steve.glendinning@shawell.net>
	<1881907.JmjSTg2PBW@linux-lqwf.site>
	<CACVXFVMNshNMJ+hYHTCfE2+UOuMgGLb0dKq8qEM-LfUseuy2qA@mail.gmail.com>
	<3108632.YdjKGB5H1R@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Steve Glendinning <steve@shawell.net>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Linux PM List <linux-pm@vger.kernel.org>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <3108632.YdjKGB5H1R@linux-lqwf.site>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CC linux-power

On Tue, Dec 11, 2012 at 11:19 PM, Oliver Neukum <oliver@neukum.org> wrote:
> On Tuesday 11 December 2012 20:53:19 Ming Lei wrote:
>> In fact, I have test data which can show a much power save
>> on OMAP3 based beagle board plus asix usbnet device with
>> the periodic work. IMO, the power save after introducing periodic
>> timer depends on the arch or platform, there should be much power
>> save if the CPU power consumption is very less. So how about letting
>> module parameter switch on/off the periodic work?
>
> You could ask on linux-power and netdev. But there would be an
> obvious question: Why kernel space?

How does user space utility know one interface doesn't support remote
wakeup for link change? and how to do it in user space?  Or could we
persuade user space guys to do it? Or could the previous user space
utility can support power save on these devices?

At least, one advantage of doing it in kernel space is that we can let
current and previous user space utility support power save on these
devices when the link is off.

Also, suppose user space utility may close interface automatically when
the link becomes off, some configurations(such as IP address) of the
network interface will be lost after it is brought up again next time once
the link becomes on. The problem might break some application.

Thanks,
--
Ming Lei
