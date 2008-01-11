From: Jeba Anandhan <jeba.anandhan@vaioni.com>
Subject: doubt in e1000_io_write()
Date: Fri, 11 Jan 2008 15:13:30 +0000
Message-ID: <1200064410.1351.3.camel@vglwks010.vgl2.office.vaioni.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vglsrv002.office.vaioni.com ([84.19.35.12]:11214 "EHLO
	vglsrv02.vgl2.office.vaioni.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759236AbYAKPPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 10:15:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
i have doubt in e1000_io_write().

void
e1000_io_write(struct e1000_hw *hw, unsigned long port, uint32_t value)
{
        outl(value, port);
}


kernel version: 2.6.12.3


Even hw structure has not been used, why it has been passed into
e1000_io_write function?

Thanks
Jeba

