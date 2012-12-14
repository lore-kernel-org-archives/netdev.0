From: Steve Glendinning <steve@shawell.net>
Subject: Re: [PATCHv2][RFC] smsc95xx: enable dynamic autosuspend
Date: Fri, 14 Dec 2012 13:35:04 +0000
Message-ID: <CAKh2mn7C3r_bvKAv4p3AHco=9JpmewOAJ8JwhtFPw50yDy5cUA@mail.gmail.com>
References: <1355239561-2740-1-git-send-email-steve.glendinning@shawell.net>
	<CACVXFVNf1EWfnQmDBDoF991cqJOb8g_Ws+tuyBJdE34rbO6GSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org,
	Oliver Neukum <oneukum@suse.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:46173 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753887Ab2LNNfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 08:35:06 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so1936360eek.19
        for <netdev@vger.kernel.org>; Fri, 14 Dec 2012 05:35:04 -0800 (PST)
In-Reply-To: <CACVXFVNf1EWfnQmDBDoF991cqJOb8g_Ws+tuyBJdE34rbO6GSw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11 December 2012 16:13, Ming Lei <ming.lei@canonical.com> wrote:
> On Tue, Dec 11, 2012 at 11:26 PM, Steve Glendinning
> <steve.glendinning@shawell.net> wrote:
>> +
>> +       if (on)
>> +               usb_autopm_get_interface_no_resume(dev->intf);
>> +       else
>> +               usb_autopm_put_interface_no_suspend(dev->intf);
>
> The above line should be
>
>           usb_autopm_put_interface(dev->intf);

Thanks Ming, I've updated this.

> IMO, it is better to keep smsc95xx_info.manage_power as NULL
> for devices without FEATURE_AUTOSUSPEND, so that fewer code
> and follow the current .mange_power usage(see its comment).
>
> Currently, if the function pointer of manage_power is set, it means that
> the device supports USB autosuspend, but your trick will make the
> assumption not true for some smsc devices.

Oliver?


--
Steve Glendinning
