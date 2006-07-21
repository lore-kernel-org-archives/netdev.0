From: Michael Buesch <mb@bu3sch.de>
Subject: Re: incorrect usage of UTS_RELEASE in bcm43xx_get_drvinfo
Date: Fri, 21 Jul 2006 21:03:23 +0200
Message-ID: <200607212103.23954.mb@bu3sch.de>
References: <20060721185945.GA7611@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jason Lunz <lunz@falooley.org>, netdev@vger.kernel.org,
	mb@bu3sch.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:27011
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751104AbWGUTEX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jul 2006 15:04:23 -0400
To: Olaf Hering <olh@suse.de>
In-Reply-To: <20060721185945.GA7611@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 21 July 2006 20:59, Olaf Hering wrote:
> 
> bcm43xx_get_drvinfo in 2.6.18-rc2 unfortunately uses UTS_RELEASE as
> driver version. I think this specific info can be obtained by other
> ways.
> Can you give bcm43xx a real version number and provide it via the
> ethtool ioctl?

I am not going to maintain a bogus version number.
What about simply returning 1.0 and be done with it.
I don't think it matters. 1.0 is as bogus as any other value.

-- 
Greetings Michael.
