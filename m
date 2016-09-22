From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: Support displaying and filtering on socket
 marks.
Date: Thu, 22 Sep 2016 16:37:52 -0700
Message-ID: <20160922163752.3688d10e@xeon-e3>
References: <1474473770-81126-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemming@brocade.com,
        zenczykowski@gmail.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34111 "EHLO
        mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753364AbcIVXhn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 19:37:43 -0400
Received: by mail-pa0-f50.google.com with SMTP id wk8so33772417pab.1
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 16:37:43 -0700 (PDT)
In-Reply-To: <1474473770-81126-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Sep 2016 01:02:50 +0900
Lorenzo Colitti <lorenzo@google.com> wrote:

> This allows the user to dump sockets with a given mark (via
> "fwmark = 0x1234/0x1234" or "fwmark = 12345", etc.) , and to
> display the socket marks of dumped sockets.
> 
> The relevant kernel commits are: d545caca827b ("net: inet: diag:
> expose the socket mark to privileged processes.") and
> - a52e95abf772 ("net: diag: allow socket bytecode filters to
> match socket marks")
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Applied to net-next.
