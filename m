From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: "Kevent 2 may have been dropped" - why?
Date: Thu, 4 Jul 2013 11:45:14 +0200 (CEST)
Message-ID: <alpine.LNX.2.02.1307041139490.30343@eeeadesso>
References: <1372905675-27383-1-git-send-email-benchan@chromium.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:38677 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961Ab3GDJo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 05:44:58 -0400
Received: by mail-ee0-f42.google.com with SMTP id c4so663893eek.1
        for <netdev@vger.kernel.org>; Thu, 04 Jul 2013 02:44:56 -0700 (PDT)
Received: from eeeadesso ([217.200.245.172])
        by mx.google.com with ESMTPSA id n45sm3892447eew.1.2013.07.04.02.44.55
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Jul 2013 02:44:56 -0700 (PDT)
In-Reply-To: <1372905675-27383-1-git-send-email-benchan@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all guys! Please CC me - as I'm not subscribed to this list!

After some hours of usage of qmi-wwan or huawei_cdc_ncm drivers, I see that 
message trigger, in file drivers/net/usb/usbnet.c at line 427.

In my dmesg, it looks like:

[183782.743539] huawei_cdc_ncm 3-2:1.1 wwan0: kevent 2 may have been dropped
[183782.743909] huawei_cdc_ncm 3-2:1.1 wwan0: kevent 2 may have been dropped
[183782.743998] huawei_cdc_ncm 3-2:1.1 wwan0: kevent 2 may have been dropped
[183782.744083] huawei_cdc_ncm 3-2:1.1 wwan0: kevent 2 may have been dropped
[183782.744166] huawei_cdc_ncm 3-2:1.1 wwan0: kevent 2 may have been dropped
[183782.744252] huawei_cdc_ncm 3-2:1.1 wwan0: kevent 2 may have been dropped
[183782.744335] huawei_cdc_ncm 3-2:1.1 wwan0: kevent 2 may have been dropped
[183782.744421] huawei_cdc_ncm 3-2:1.1 wwan0: kevent 2 may have been dropped
[183782.744504] huawei_cdc_ncm 3-2:1.1 wwan0: kevent 2 may have been dropped
[183782.744586] huawei_cdc_ncm 3-2:1.1 wwan0: kevent 2 may have been dropped

And the same happens with qmi_wwan.
I understand this is related to kernel workqueue mechanism - but don't 
understand exactly why it triggers, and if we can do something.
thank you!
