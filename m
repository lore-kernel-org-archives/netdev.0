From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] fix reuseaddr regression
Date: Tue, 19 Sep 2017 13:50:56 -0700 (PDT)
Message-ID: <20170919.135056.44228457394918392.davem@davemloft.net>
References: <1505752137-15522-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        crobinso@redhat.com, labbott@redhat.com, kernel-team@fb.com
To: josef@toxicpanda.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44600 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751547AbdISUu5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 16:50:57 -0400
In-Reply-To: <1505752137-15522-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: josef@toxicpanda.com
Date: Mon, 18 Sep 2017 12:28:54 -0400

> I introduced a regression when reworking the fastreuse port stuff that allows
> bind conflicts to occur once a reuseaddr socket successfully opens on an
> existing tb.  The root cause is I reversed an if statement which caused us to
> set the tb as if there were no owners on the socket if there were, which
> obviously is not correct.
> 
> Dave I have follow up patches that will add a selftest for this case and I ran
> the other reuseport related tests as well.  These need to go in pretty quickly
> as it breaks kvm, I've marked them for stable.  Sorry for the regression,

First, please fix your "From: " field so that it actually has your full
name rather than just your email address.  This matter when I apply
your patches.

Second, remove the stable CC:.  For networking changes, you simply ask
me to queue the changes up for -stable.

Thanks.
