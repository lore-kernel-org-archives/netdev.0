From: Denis Joseph Barrow <D.Barow@option.com>
Subject: re hso 2.6.29-rc1 driver
Date: Tue, 13 Jan 2009 12:47:39 +0100
Message-ID: <496C7F5B.7030405@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux USB kernel mailing list <linux-usb@vger.kernel.org>,
	Linux netdev Mailing list <netdev@vger.kernel.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.option.com ([81.246.70.163]:23790 "EHLO
	mailer2.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752480AbZAMLrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 06:47:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alan,
The tty low_latency variable is set to 1 in hso_serial_open in linux,
Maybe you were removing duplicate setting of this variable but
if it was your intention to set it to 0 it's not being done.
Also the 2.6.29-rc1 driver hangs the kernel on linux-2.6.28-rc6 when a device is connected,
I've still got to test it on 2.6.29-rc1.
-- 
best regards,
D.J. Barrow

Linux Kernel Developer
Option NV, Gaston Geenslaan 14, 3001 Leuven, Belgium
 
T: +32 16 311 621
F: +32 16 207 164
d.barow@option.com
www.option.com

Disclaimer:
http://www.option.com/company/disclaimer.shtml
