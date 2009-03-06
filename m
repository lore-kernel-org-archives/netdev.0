From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] macvlan: Support creating macvlans from macvlans
Date: Fri, 06 Mar 2009 14:54:40 +0100
Message-ID: <49B12B20.7000602@trash.net>
References: <m1ocwfsgw7.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63322 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752864AbZCFNyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2009 08:54:45 -0500
In-Reply-To: <m1ocwfsgw7.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> When running in a network namespace whose only link to
> the outside world is a macvlan device, not being
> able to create another macvlan is a real pain.
> 
> So modify macvlan creation to allow automatically forward
> a creation of a macvlan on a macvlan to become a creation
> of a macvlan on the underlying network device.

I'm not sure I understand the constallation, what is the underlying
device in this case? A device outside the namespace?

