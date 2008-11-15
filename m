From: Andi Kleen <andi@firstfloor.org>
Subject: Re: tcp_tw_recycle broken?
Date: Sat, 15 Nov 2008 14:09:04 +0100
Message-ID: <874p2916hb.fsf@basil.nowhere.org>
References: <f9be06770811142037v794cf4f8w7a82ab45c0f3820c@mail.gmail.com>
	<20081115055748.GY24654@1wt.eu>
	<f9be06770811142329x7d6dcb89vd573962970d503b3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Karl Pickett" <karl.pickett@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:51517 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755033AbYKONJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Nov 2008 08:09:02 -0500
In-Reply-To: <f9be06770811142329x7d6dcb89vd573962970d503b3@mail.gmail.com> (Karl Pickett's message of "Sat, 15 Nov 2008 02:29:27 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Karl Pickett" <karl.pickett@gmail.com> writes:
>
> May I just confirm.. is tcp_tw_reuse NOT dependent on receiving timestamps?

The big problem is that both are incompatible with NAT. So if you
ever talk to any NATed clients don't use it.

-Andi

-- 
ak@linux.intel.com
