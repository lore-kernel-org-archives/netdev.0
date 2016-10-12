From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 iproute2 0/9] Cleanup backlog
Date: Wed, 12 Oct 2016 15:26:17 -0700
Message-ID: <20161012152617.2018090c@xeon-e3>
References: <1476183648-25850-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mrv@mojatatu.com, cdillaba@mojatatu.com,
        lucasb@mojatatu.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33190 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753189AbcJLWbY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 18:31:24 -0400
Received: by mail-pf0-f178.google.com with SMTP id 128so25024784pfz.0
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 15:31:24 -0700 (PDT)
In-Reply-To: <1476183648-25850-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Oct 2016 07:00:39 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> 
> Variety of cleanup and new functionality I had sitting around on my
> private tree
> 
> Craig Dillabaugh (1):
>   action gact: list pipe as a valid action
> 
> Jamal Hadi Salim (3):
>   actions ife: Introduce encoding and decoding of tcindex metadata
>   actions:  add skbmod action
>   man pages: Add tc-ife to Makefile
> 
> Lucas Bates (2):
>   man pages: update ife action to include tcindex
>   man pages: add man page for skbmod action
> 
> Roman Mashak (3):
>   ife action: allow specifying index in hex
>   ife: print prio, mark and hash as unsigned
>   ife: improve help text
> 
>  include/linux/tc_act/tc_ife.h |   3 +-
>  man/man8/Makefile             |   2 +-
>  man/man8/tc-ife.8             |  29 ++++-
>  tc/m_gact.c                   |   4 +-
>  tc/m_ife.c                    |  38 ++++--
>  tc/m_skbmod.c                 | 260 ++++++++++++++++++++++++++++++++++++++++++
>  6 files changed, 319 insertions(+), 17 deletions(-)
>  create mode 100644 tc/m_skbmod.c
> 

Applied. Then went through and cleaned up minor checkpatch style issues.
