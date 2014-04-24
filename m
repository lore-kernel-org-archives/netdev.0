From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Subject: Re: [ovs-dev] [PATCH v2.56] datapath: Add basic MPLS support to
 kernel
Date: Thu, 24 Apr 2014 17:57:29 +0900 (JST)
Message-ID: <20140424085729.CBE6671E58@kuma.localdomain>
References: <1396323981-20700-2-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org, jesse@nicira.com,
	pshelar@nicira.com, rkerur@gmail.com
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.valinux.co.jp ([210.128.90.3]:46156 "EHLO
	mail.valinux.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752878AbaDXI5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 04:57:30 -0400
In-Reply-To: Your message of "Tue,  1 Apr 2014 12:46:21 +0900"
	<1396323981-20700-2-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,

> + * Due to the sample action there may be multiple possible eth types.
> + * In order to correctly validate actions all possible types are tracked
> + * and verified. This is done using struct eth_types.

is there any real-world use cases of these actions inside a sample?
otherwise, how about just rejecting such combinations?
it doesn't seem to worth the code complexity to me.
(sorry if it has been already discussed.  it's the first time for me
to seriously read this long-lived patch.)

YAMAMOTO Takashi
