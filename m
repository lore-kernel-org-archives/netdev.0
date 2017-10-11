From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Ethtool question
Date: Wed, 11 Oct 2017 16:44:07 -0400
Message-ID: <20171011204406.GC30940@tuxdriver.com>
References: <492e57b2-ac0a-ff01-2698-e048e97d8e37@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45591 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757495AbdJKUpO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 16:45:14 -0400
Content-Disposition: inline
In-Reply-To: <492e57b2-ac0a-ff01-2698-e048e97d8e37@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 11, 2017 at 09:51:56AM -0700, Ben Greear wrote:
> I noticed today that setting some ethtool settings to the same value
> returns an error code.  I would think this should silently return
> success instead?  Makes it easier to call it from scripts this way:
> 
> [root@lf0313-6477 lanforge]# ethtool -L eth3 combined 1
> combined unmodified, ignoring
> no channel parameters changed, aborting
> current values: tx 0 rx 0 other 1 combined 1
> [root@lf0313-6477 lanforge]# echo $?
> 1

I just had this discussion a couple of months ago with someone. My
initial feeling was like you, a no-op is not a failure. But someone
convinced me otherwise...I will now endeavour to remember who that
was and how they convinced me...

Anyone else have input here?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
