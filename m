From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Unplug ethernet cable, the route persists.  Why?
Date: Thu, 25 Nov 2010 23:18:35 +0100
Message-ID: <4CEEE0BB.6020509@gmail.com>
References: <144174.46619.qm@web63401.mail.re1.yahoo.com> <87bp5df9j9.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Mike Caoco <caoco2002@yahoo.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Ben Gamari <bgamari@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46524 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752387Ab0KYWSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 17:18:41 -0500
In-Reply-To: <87bp5df9j9.fsf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Gamari wrote:
> On Wed, 24 Nov 2010 12:29:43 -0800 (PST), Mike Caoco <caoco2002@yahoo.com> wrote:
>> So if you rely on NetworkManager or Connman or Quagga to remove the
>> route, the routing daemons will recompute the route table anyway.  So
>> why cannot this be done in the kernel?
> 
> This is policy. In the Linux world we generally strive to separate
> policy from mechanism, leaving the former to userspace. This allows
> (potentially complex) policy decisions to be made in user-space. The
> reason for this is two-fold: First, every line of kernel code introduces
> the potentially for a bug and error handling in the kernel is generally
> more complex than it is in user-space. Secondly, allowing user-space to
> handle policy allows users to do things with the kernel that kernel
> developers did not envision. This flexibility is one reason why the
> kernel is so suited for running on anything from your cell-phone to 4000
> processor big iron.

Secondly and a half, if you add a specific route you may really
mean it, and prefer not to send at all than use default.

Cheers,
Jarek P.
