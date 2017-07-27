From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] geneve: support for modifying geneve device
Date: Thu, 27 Jul 2017 11:24:37 -0700
Message-ID: <20170727112437.4e548cdc@xeon-e3>
References: <1501035103-3090-1-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Girish Moodalbail <girish.moodalbail@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:32780 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751458AbdG0SYj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 14:24:39 -0400
Received: by mail-pf0-f172.google.com with SMTP id d67so18656383pfc.0
        for <netdev@vger.kernel.org>; Thu, 27 Jul 2017 11:24:39 -0700 (PDT)
In-Reply-To: <1501035103-3090-1-git-send-email-girish.moodalbail@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Jul 2017 19:11:43 -0700
Girish Moodalbail <girish.moodalbail@oracle.com> wrote:

> Ability to change geneve device attributes was added to kernel through
> commit 5b861f6baa3a ("geneve: add rtnl changelink support"), however one
> cannot do the same through ip-link(8) command.  Changing the allowed
> geneve device attributes using 'ip link set <geneve_name> type geneve id
> <geneve_id> <allowed_attributes>' currently fails with 'operation not
> supported' error.  This patch adds support for it.
> 
> Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>

Looks good, applied.
Please send a follow on patch to update usage help and man page.
