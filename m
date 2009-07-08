From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] don't touch bridge sysfs in container.
Date: Wed, 8 Jul 2009 09:33:20 -0700
Message-ID: <20090708093320.1416dfd8@nehalam>
References: <871vorcrrm.wl%chamas@h4.dion.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chamas@h4.dion.ne.jp
To: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36137 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753570AbZGHQd1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jul 2009 12:33:27 -0400
In-Reply-To: <871vorcrrm.wl%chamas@h4.dion.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 08 Jul 2009 20:56:29 +0900
Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp> wrote:

>  Hello,
> 
> netns don't have own sysfs. we should not touch sysfs not on init_net?
> I am sorry I've lost my own mail, titled
> 
>   kernel BUG at fs/sysfs/group.c:65!
> 
> below will only fixes this.
> 
> Signed-off-by: Ken-ichirou MATSUZAWA

There is a per netns sysfs interface, it should be changed to use that.
