From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Tue, 27 Jun 2006 18:31:01 +0200
Message-ID: <200606271831.02108.mb@bu3sch.de>
References: <20060626212547.GE30706@tuxdriver.com> <200606271725.26037.mb@bu3sch.de> <44A158EB.90406@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de,
	Larry Finger <Larry.Finger@lwfinger.net>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:35218
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1161159AbWF0QbM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 12:31:12 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44A158EB.90406@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 27 June 2006 18:12, Jeff Garzik wrote:
> Michael Buesch wrote:
> > So, I will submit a patch to lower the udelay(10) to udelay(1)
> > and we can close the discussion? ;)
> 
> No, that totally avoids my point.  Your "otherwise idle machine" test is 
> probably nowhere near worst case in the field, for loops that can 
> potentially lock the CPU for a long time upon hardware fault.  And then 
> there are the huge delays in specific functions that I pointed out...

wtf are you requesting from me?
1) I proved you that the loop does only spin _once_ or even _less_.
2) If the hardware is faulty, the user must replace it.
   Because, if the hardware is faulty, it can crash the whole
   machine anyway, obviously.

3) There is no "huge delay". I proved it with my logs.
   -> No CPU hog => Nothing to fix.

-- 
Greetings Michael.
