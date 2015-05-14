From: John Whitmore <arigead@gmail.com>
Subject: GSM Modem management?
Date: Thu, 14 May 2015 20:44:43 +0100
Message-ID: <20150514194442.GA21972@bamboo.electronicsoup>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:34851 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964992AbbENTrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 15:47:40 -0400
Received: by wgnd10 with SMTP id d10so84585566wgn.2
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 12:47:39 -0700 (PDT)
Received: from bamboo.electronicsoup (86-44-189-100-dynamic.agg2.cty.lmk-pgs.eircom.net. [86.44.189.100])
        by mx.google.com with ESMTPSA id ng5sm14767321wic.24.2015.05.14.12.47.37
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 12:47:37 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chances are that I'm in the wrong place here, "Linux" networking having so many
parts, many of which aren't in the kernel, that being said this might be
considered the centre of it all, so I thought I'd start here and see if
somebody would point me in a direction that was better placed to answer some
of my queries.

I'm working on a mobile system, RaspberryPi based, which has two 4G USB
Dongles for communications to the Internet. Both dongles are the same make and
model but have different service provider sims. The idea being that if one has
no coverage hopefully the other does have some degree of connectivity. I
started by connecting up to the internet using network-manager-gnome for a
single dongle. Unfortunately when I started a ping test after a couple of ping
messages it crashed the whole raspbian system without any message going to
/var/log/messages. Totally locked up. 

Having failed with the Network-manager I used wvdial to establish a connection
and that is as happy as larry, pinging away. 

My questions are to do with how to manage two identical Dongles. At present
when usb-modeswitch ejects them, from CD Drive, into modem configuration, when
"qmi_wwan" assignes a network name. I'd like to assign udev rules to assign
carrier based names to the network interfaces. I'm not sure if udev will
interfere with qmi_wwan? 

That is possibly the easy part. I then want to attach some logic to manage the
connections in a very basic manner and perhaps display connectivity
information to the user on the desktop. Could somebody tell me where this
functionality would be added? I assume that ppp has no idea about GSM signal
strength. It'd be great if a simple user space program could monitor DBus and
bring up or drop the connections as conditions change, but I guess that might
be asking for a little bit much. So if not ppp what sub-system controls the
Modem? 

Thanks for any help.
