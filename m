From: "Michael D. Berger" <m_d_berger_1900@yahoo.com>
Subject: Fail Transfer of Large Files
Date: Fri, 19 Nov 2010 23:45:14 +0000 (UTC)
Message-ID: <ic726a$dep$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:42979 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932558Ab0KSXp0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Nov 2010 18:45:26 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1PJadx-0002lX-9u
	for netdev@vger.kernel.org; Sat, 20 Nov 2010 00:45:25 +0100
Received: from static-71-246-219-24.washdc.fios.verizon.net ([71.246.219.24])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 20 Nov 2010 00:45:25 +0100
Received: from m_d_berger_1900 by static-71-246-219-24.washdc.fios.verizon.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 20 Nov 2010 00:45:25 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On my intranet, I sometimes transfer large files, about 4G,
to an CentOS old box that I use for a web server.  I transfer
with ftp or sftp.  Usually, before the file is complete, the
transfer "stalls".  At that point, ping from the destination box
to the router fails.  I then deactivate the net interface on the
destination box and then activate it.  Ping is then successful,
and the transfer is completed.  The transferred file is correct,
as verified with sha1sum.

All connections are via cat6 wire.

So what do you think?  Should I try changing the net card?
Any tests to run? Any other suggestions?

Thanks for your help.

Mike.

