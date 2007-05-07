From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Mon, 7 May 2007 19:38:11 -0400
Message-ID: <20070507233811.GB4245@tuxdriver.com>
References: <20070507175121.GF5125@tuxdriver.com> <463FB1A0.3070608@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4689 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967313AbXEHAC1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 20:02:27 -0400
Content-Disposition: inline
In-Reply-To: <463FB1A0.3070608@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 07, 2007 at 07:09:20PM -0400, Jeff Garzik wrote:
> John W. Linville wrote:

> >Ivo van Doorn (1):
> >      Add 93cx6 eeprom library

> >Michael Wu (1):
> >      Add rtl8187 wireless driver

I presume these are the two parts you question.  (Just checking...)

> The normal development process is:
> 
> * commit new code to your repository
> * that goes into -mm for public testing and review
> * merge window opens
> * the code that has seen public testing and review goes upstream
> 
> The general idea is everything you want in 2.6.22 should be prepared and 
> in -mm BEFORE 2.6.21 is released, and the 2.6.22 merge window opens.
> 
> It's quite normal for fixes and minor changes to trickle in after the 
> push that follows the merge window opening.  But new drivers that have 
> not been through this process do not fall under "fixes and minor changes."
 
I agree whole-heartedly.

The whole mac80211 driver package (including rtl8187) has been in -mm
(and rawhide) for most of the 2.6.21 development cycle.  The rtl8187
driver in particular has been relatively stable for the past couple
of months ("3 files changed, 13 insertions(+), 4 deletions(-)" since
7 March 2007), and it seems to work well.

> I also did not see any response to my "better as a single file driver" 
> suggestion.

Yes, I see that now.  Do you consider this a merge requirement?

My main concern pre-merge would be accidentally destabilizing the code
while stitching the files together.  Other than that, the suggestion
seems worthwhile.  However, I think Michael plans to expand the driver
to support rtl8180 and rtl8185.  This may factor into why he chose
to organize the code the way he has.

> So, I'll pull if you remove the two late additions.

Any chance that you find the comments above persuasive? :-)

John
-- 
John W. Linville
linville@tuxdriver.com
