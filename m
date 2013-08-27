From: David Miller <davem@davemloft.net>
Subject: Re: [net-next RFC 6/7] i40evf: init code and hardware support
Date: Tue, 27 Aug 2013 14:44:08 -0400 (EDT)
Message-ID: <20130827.144408.632457019633507990.davem@davemloft.net>
References: <1377233609-11627-7-git-send-email-jeffrey.t.kirsher@intel.com>
	<1377625357.13272.54.camel@bwh-desktop.uk.level5networks.com>
	<CALWPMBHKfzvLpi9J+tqeFtmOzPANXw5ozdiXhSku_sQtVGg5yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jeffrey.t.kirsher@intel.com,
	mitch.a.williams@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: john.ronciak@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58228 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752338Ab3H0SoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 14:44:11 -0400
In-Reply-To: <CALWPMBHKfzvLpi9J+tqeFtmOzPANXw5ozdiXhSku_sQtVGg5yg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Ronciak <john.ronciak@gmail.com>
Date: Tue, 27 Aug 2013 11:39:03 -0700

>> I wonder why this is thought to be necessary.  I've never heard of
>> copyright assignment conditions being accepted in the Linux kernel.
> 
>> Some Linux drivers are dual-licenced under a permissive licence and GPL,
>> and all contributions to them presumably also have to be dual-licenced.
>> It seems like that would allow you to retain the ability to reuse the
>> core hardware code on other operating systems and under proprietary
>> licences, even with copyrightable contributions from others.
> 
> The problem here is that it's a legal issue.  The Intel lawyers (and I've
> heard form other companies on this as well) say that just because we
> release code under a dual license does not mean that any changes (patches)
> that come back are also under a dual license.  That cannot be assumed.  So
> all changes would require us to ask that the patches in question are being
> supplied under the same dual license.  This can get unmanageable fairly
> quickly.  There is also long term tracking of those requests/responses.  So
> using a dual license isn't the same thing unfortunately.

I think it's pretty anti-social to not accept changes made outside of
your group.

I don't want Intel ethernet drivers to go the way of ACPI where nobody
outside of you guys can make changes to the code.

I guarentee I will want to make changes to your drivers if an interface
is changed and I have to touch your code to keep the tree building when
a function signature changes.

To say that I am upset about this would be an understatement, it blocks
normal smooth development of networking infrastructure.
