From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] tc: m_ife: fix match tcindex parsing
Date: Tue, 31 Oct 2017 17:59:02 +0100
Message-ID: <20171031175902.69fbf465@shemminger-XPS-13-9360>
References: <20171030163749.31291-1-aring@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: Alexander Aring <aring@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:48185 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753653AbdJaQ71 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 12:59:27 -0400
Received: by mail-lf0-f67.google.com with SMTP id a69so19836540lfe.5
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 09:59:26 -0700 (PDT)
In-Reply-To: <20171030163749.31291-1-aring@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Oct 2017 12:37:49 -0400
Alexander Aring <aring@mojatatu.com> wrote:

> This patch changes ife_prio to ife_tcindex which is right variable to
> assign in the argument in this case.
> 
> Signed-off-by: Alexander Aring <aring@mojatatu.com>
> ---
> Found by inspection the code.

Good catch.
I wonder if anybody ever used or tested this code path. Unlikely
