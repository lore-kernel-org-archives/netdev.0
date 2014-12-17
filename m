From: John <jw@nuclearfallout.net>
Subject: Re: [Xen-devel] xen-netback: make feature-rx-notify mandatory --
 Breaks stubdoms
Date: Wed, 17 Dec 2014 15:29:38 -0800
Message-ID: <549211E2.8030901@nuclearfallout.net>
References: <54884DA8.7030003@nuclearfallout.net> <548854C3.7060008@citrix.com> <54918C89.1020409@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	"Xen-devel@lists.xen.org" <Xen-devel@lists.xen.org>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nuclearfallout.net ([208.146.45.251]:46440 "EHLO
	mail.nuclearfallout.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981AbaLQXiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 18:38:17 -0500
In-Reply-To: <54918C89.1020409@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/2014 6:00 AM, David Vrabel wrote:
> This patch works for me.  I tested it with a hacked Linux frontend that
> disabled feature-rx-notify, but not with a stubdom.
>
> Can you give it a try, please?

I tested this and it does seem to work -- at least, a stubdom-based domU 
starts up and runs properly. That said, I'm not using the minios network 
functionality much, since all of my customer and test domains use PVHVM 
drivers.

-John
