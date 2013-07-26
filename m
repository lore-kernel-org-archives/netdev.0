From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v6] vxlan: Allow setting destination to unicast
 address.
Date: Fri, 26 Jul 2013 14:26:35 -0700
Message-ID: <20130726142635.6945d0b0@nehalam.linuxnetplumber.net>
References: <87txjklfg2.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Stevens <dlstevens@us.ibm.com>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>
To: Atzm Watanabe <atzm@stratosphere.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f65.google.com ([209.85.160.65]:48338 "EHLO
	mail-pb0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933710Ab3GZVbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 17:31:18 -0400
Received: by mail-pb0-f65.google.com with SMTP id un1so1011747pbc.0
        for <netdev@vger.kernel.org>; Fri, 26 Jul 2013 14:31:17 -0700 (PDT)
In-Reply-To: <87txjklfg2.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Jul 2013 14:01:01 +0900
Atzm Watanabe <atzm@stratosphere.co.jp> wrote:

> This patch allows setting VXLAN destination to unicast address.
> It allows that VXLAN can be used as peer-to-peer tunnel without
> multicast.
> 
> v6: change back to the v3 except for using new attribute because
>     replacing command-line parameters breaks existing scripts,
>     based by Cong Wang's comments.
> 
> v5: rebase on the latest.
> 
> v4: replace "group" with "remote" based by David Stevens's comments.
> 
> v3: move a new attribute REMOTE into the last of an enum list
>     based by Stephen Hemminger's comments.
>     fix the usage to show explicitly that both "remote" and "group"
>     cannot be specified, based by Ben Hutchings's comments.
> 
> v2: use a new argument "remote" instead of "group" based by
>     Stephen Hemminger's comments.
> 
> Signed-off-by: Atzm Watanabe <atzm@stratosphere.co.jp>

Applied
