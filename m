From: Andres Freund <andres@anarazel.de>
Subject: Re: [PATCH net] net: fix sysfs symlinks of adjacent devices
Date: Fri, 19 Sep 2014 10:59:25 +0200
Message-ID: <20140919085925.GE4277@alap3.anarazel.de>
References: <1410516826-6926-1-git-send-email-git.user@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>,
	Vlad Yasevich <vyasevic@redhat.com>
To: Alexander Fomichev <git.user@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.anarazel.de ([217.115.131.40]:53072 "EHLO mail.anarazel.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751244AbaISI7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2014 04:59:30 -0400
Content-Disposition: inline
In-Reply-To: <1410516826-6926-1-git-send-email-git.user@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 2014-09-12 14:13:46 +0400, Alexander Fomichev wrote:
> From: "Alexander Y. Fomichev" <git.user@gmail.com>
> 
> __netdev_adjacent_dev_insert may add adjacent device from another
> namespace. Without proper check it leads to emergence of broken
> symlink from/to device not existing in current namespace.
> Fix: check net_ns is the same before netdev_adjacent_sysfs_add/del
> related to: 4c75431ac3520631f1d9e74aa88407e6374dbbc4
> 

This version, applied on top of 8ba4caf1ee, fixes the bug I had
reported. Not just the testcase, but the actual usage scenario.

I haven't tested David's version, but it doesn't look likely to be
materially different.

Greetings,

Andres Freund
