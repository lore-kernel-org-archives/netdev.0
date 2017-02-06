From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2/net-next 0/3] Add the tc-sample action
Date: Mon, 6 Feb 2017 14:26:20 -0800
Message-ID: <20170206142620.3e640740@xeon-e3>
References: <1486281534-61663-1-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, eladr@mellanox.com
To: Yotam Gigi <yotamg@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34940 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751314AbdBFW02 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 17:26:28 -0500
Received: by mail-pf0-f181.google.com with SMTP id f144so27111166pfa.2
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 14:26:28 -0800 (PST)
In-Reply-To: <1486281534-61663-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun,  5 Feb 2017 09:58:51 +0200
Yotam Gigi <yotamg@mellanox.com> wrote:

> This patchset adds the tc-sample action support and the corresponding man
> page. More information about the action and its usage can be found in the
> commit message.
> 
> Yotam Gigi (3):
>   tc: Add support for the sample tc action
>   tc: man: Add man entry for the tc-sample action
>   tc: man: matchall: Update examples to include sample
> 
>  bash-completion/tc               |   8 +-
>  include/linux/tc_act/tc_sample.h |  26 ++++++
>  man/man8/Makefile                |   2 +-
>  man/man8/tc-matchall.8           |  10 +++
>  man/man8/tc-sample.8             | 125 ++++++++++++++++++++++++++
>  tc/Makefile                      |   1 +
>  tc/m_sample.c                    | 186 +++++++++++++++++++++++++++++++++++++++
>  7 files changed, 356 insertions(+), 2 deletions(-)
>  create mode 100644 include/linux/tc_act/tc_sample.h
>  create mode 100644 man/man8/tc-sample.8
>  create mode 100644 tc/m_sample.c
> 

Applied to net-next. I had to fix merge conflict on tc/Makefile
