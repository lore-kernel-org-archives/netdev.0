From: Jon Mason <jon.mason@exar.com>
Subject: Re: [PATCH 01/11] vxge: enable rxhash
Date: Mon, 8 Nov 2010 16:53:40 -0600
Message-ID: <20101108225340.GA16247@exar.com>
References: <1288911122-28669-1-git-send-email-jon.mason@exar.com>
 <20101108.124452.115944240.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sivakumar Subramani <Sivakumar.Subramani@exar.com>,
	Sreenivasa Honnur <Sreenivasa.Honnur@exar.com>,
	Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:63484 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752852Ab0KHWxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 17:53:49 -0500
Received: by yxk8 with SMTP id 8so3843773yxk.19
        for <netdev@vger.kernel.org>; Mon, 08 Nov 2010 14:53:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20101108.124452.115944240.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 08, 2010 at 12:44:52PM -0800, David Miller wrote:
> 
> This patch set doesn't apply at all to the current tree, please
> respin them, thanks.

When I sent out the series on Thursday, the tree did not have
"vxge: make functions local and remove dead code".  When that patch
was originally released (Oct 15), I asked for it to not be included as
it would break soon-to-be-released patch series.  I did not see any
e-mail afterward, so I assumed this was acceptable to you.  We then
ran the driver though our internal tests to verify its functionality,
which would need to be re-done if the patches are respun.

I have a reworked version of that patch which can be applied after
this patch series.  Is it acceptable to you to revert the commit,
apply the series, then apply the modified version of the "local
functions" patch?  I have already sniff tested it on our hardware
without issues.

Thanks,
Jon
