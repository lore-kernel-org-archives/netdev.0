From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Tue, 27 Jun 2006 12:12:27 -0400
Message-ID: <44A158EB.90406@garzik.org>
References: <20060626212547.GE30706@tuxdriver.com> <200606271530.06749.mb@bu3sch.de> <44A13C81.2050503@garzik.org> <200606271725.26037.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de,
	Larry Finger <Larry.Finger@lwfinger.net>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53384 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1161142AbWF0QMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2006 12:12:30 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200606271725.26037.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> So, I will submit a patch to lower the udelay(10) to udelay(1)
> and we can close the discussion? ;)

No, that totally avoids my point.  Your "otherwise idle machine" test is 
probably nowhere near worst case in the field, for loops that can 
potentially lock the CPU for a long time upon hardware fault.  And then 
there are the huge delays in specific functions that I pointed out...

	Jeff


