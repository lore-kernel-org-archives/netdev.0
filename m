From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH iproute2] devlink: Convert conditional in
 dl_argv_handle_port() to switch()
Date: Sun, 9 Oct 2016 11:10:11 +0200
Message-ID: <20161009090707.BF9437C8DC@mail.nwl.cc>
References: <1475979258-29222-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:53284 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754503AbcJIJHK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 9 Oct 2016 05:07:10 -0400
Content-Disposition: inline
In-Reply-To: <1475979258-29222-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 09, 2016 at 10:14:18AM +0800, Hangbin Liu wrote:
> Discovered by Phil's covscan. The final return statement is never reached.
> This is not inherently clear from looking at the code, so change the
> conditional to a switch() statement which should clarify this.
> 
> CC: Phil Sutter <phil@nwl.cc>
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>

Acked-by: Phil Sutter <phil@nwl.cc>
