From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] net: Support ip route get via given table
Date: Wed, 2 Sep 2015 21:12:44 +0200
Message-ID: <20150902191244.GE20527@pox.localdomain>
References: <1441220592-7339-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:33952 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060AbbIBTMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 15:12:46 -0400
Received: by wicfx3 with SMTP id fx3so27679187wic.1
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 12:12:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1441220592-7339-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/15 at 12:03pm, David Ahern wrote:
> Add support for 'ip [-6] route get table X' where the user wants to
> force the FIB lookup from a given table.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Will you use this outside of 'ip route get' as well? If so, how? I'm
asking because you propose to add the check and new behaviour to bypass
the routing rules to the routing fastpath, wouldn't it be better to
handle this in inet_rtm_getroute()?
