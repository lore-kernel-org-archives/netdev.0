From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] compile error in ieee80211_ioctl.c
Date: Wed, 26 Apr 2006 16:49:43 -0400
Message-ID: <20060426204937.GF7922@tuxdriver.com>
References: <20060425211236.GC19116@tuxdriver.com> <20060426162946.38818.qmail@web50212.mail.yahoo.com> <20060426183734.4ac5dc6c@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alex Davis <alex14641@yahoo.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:52497 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S932398AbWDZUt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2006 16:49:58 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20060426183734.4ac5dc6c@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 26, 2006 at 06:37:34PM +0200, Jiri Benc wrote:
> On Wed, 26 Apr 2006 09:29:46 -0700 (PDT), Alex Davis wrote:
> > Here is an updated patch which addresses Randy's issues. I'm currently running
> > this with no problems:
> > [...]
> > +module_param(ieee80211_regdom, int, 0666);
> >  MODULE_PARM_DESC(ieee80211_regdom, "IEEE 802.11 regulatory domain; 64=MKK");
> 
> NAK. Those parameters should not be writable yet.
> 
> Please see
> http://marc.theaimsgroup.com/?l=linux-netdev&m=114565040832451&w=2 for
> the correct patch (hopefully John will pull it soon).

This has now been addressed.

Thanks!

John
-- 
John W. Linville
linville@tuxdriver.com
