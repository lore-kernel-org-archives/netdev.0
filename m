From: Lucas Bates <lucasb@mojatatu.com>
Subject: Re: [PATCH net-next] tc-testing: better check if thing is list
Date: Tue, 31 Oct 2017 14:43:29 -0400
Message-ID: <CAMDBHYJ=+vQ8apBMU+XD1ybLVQXP1MopVM66ZKD3bTkHe2MuhA@mail.gmail.com>
References: <20171031182835.9834-1-bjb@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: davem@davemloft.net, Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>, Chris Mi <chrism@mellanox.com>,
        Alexander Aring <aring@mojatatu.com>,
        Roman Mashak <mrv@mojatatu.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: "Brenda J. Butler" <bjb@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:56895 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932584AbdJaSnu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:43:50 -0400
Received: by mail-wm0-f53.google.com with SMTP id z3so725600wme.5
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:43:50 -0700 (PDT)
In-Reply-To: <20171031182835.9834-1-bjb@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 2:28 PM, Brenda J. Butler <bjb@mojatatu.com> wrote:
> Check if tcase[k] is an instance of a list (is or is derived from list)
> instead of checking if it is a list.
>
> This will be useful if the data structures change to be something
> that implements list, instead of being an actual list.  In that
> case, this code will not have to change.
>
> Signed-off-by: Brenda J. Butler <bjb@mojatatu.com>
Acked-by: Lucas Bates <lucasb@mojatatu.com>
