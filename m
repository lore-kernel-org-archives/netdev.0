From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Wed, 25 Apr 2007 07:36:43 -0400
Message-ID: <1177501003.4082.20.camel@localhost>
References: <20070425013920.6031.30149.stgit@gitlost.site>
	 <462ED398.5080405@linux-foundation.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, cramerj@intel.com, auke-jan.h.kok@intel.com,
	christopher.leech@intel.com, davem@davemloft.net
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.235]:58501 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992716AbXDYLgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 07:36:48 -0400
Received: by wr-out-0506.google.com with SMTP id 76so195844wra
        for <netdev@vger.kernel.org>; Wed, 25 Apr 2007 04:36:47 -0700 (PDT)
In-Reply-To: <462ED398.5080405@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-24-04 at 21:05 -0700, Stephen Hemminger wrote:
> Peter P Waskiewicz Jr wrote:

> Only if this binary compatiable with older kernels.

It is not. But i think that is a lesser problem, the bigger question is:
Why would you need to change a qdisc just so you can support egress
multiqueues?

BTW, is there any reason this is being cced to lkml?

cheers,
jamal

PS:- I havent read the kernel patches (i am congested and about 1000
messages behind on netdev) and my opinions may be influenced by an
approach i have in trying to help someone fixup a wireless driver with
multiqueue support.

