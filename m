From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] don't touch bridge sysfs in container.
Date: Thu, 9 Jul 2009 14:23:17 -0700
Message-ID: <20090709142317.542c51a4@nehalam>
References: <871vorcrrm.wl%chamas@h4.dion.ne.jp>
	<20090708093320.1416dfd8@nehalam>
	<877hyicf4x.wl%chamas@h4.dion.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>,
	netdev@vger.kernel.org
To: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34001 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754059AbZGIVXX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2009 17:23:23 -0400
In-Reply-To: <877hyicf4x.wl%chamas@h4.dion.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 09 Jul 2009 19:41:34 +0900
Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp> wrote:

>  Hello,
> 
> At Wed, 8 Jul 2009 09:33:20 -0700,
> Stephen Hemminger wrote:
> 
> > There is a per netns sysfs interface, it should be changed to use that.
> 
> Sorry, I can see only:
> 
>     - add netns suffix was disagreed
>     - tagged sysfs may not be merged

Without tagged sysfs, how could bridge interface work in other containers?


-- 
