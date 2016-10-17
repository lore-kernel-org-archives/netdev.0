From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] devlink: Convert conditional in
 dl_argv_handle_port() to switch()
Date: Mon, 17 Oct 2016 05:31:19 -0700
Message-ID: <20161017053119.38ef5dbc@xeon-e3>
References: <1475979258-29222-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34383 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934233AbcJQMbF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 08:31:05 -0400
Received: by mail-pf0-f179.google.com with SMTP id r16so55576960pfg.1
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 05:31:05 -0700 (PDT)
In-Reply-To: <1475979258-29222-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun,  9 Oct 2016 10:14:18 +0800
Hangbin Liu <liuhangbin@gmail.com> wrote:

> Discovered by Phil's covscan. The final return statement is never reached.
> This is not inherently clear from looking at the code, so change the
> conditional to a switch() statement which should clarify this.
> 
> CC: Phil Sutter <phil@nwl.cc>
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>

Applied thanks
