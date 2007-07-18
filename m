From: "rae l" <crquan@gmail.com>
Subject: Re: [PATCH 2/2] net/core: some functions' definition order adjustment for readability
Date: Wed, 18 Jul 2007 22:31:37 +0800
Message-ID: <91b13c310707180731w58e7dfaau4d7668e24a1f6ec7@mail.gmail.com>
References: <20070718.030306.50591269.davem@davemloft.net>
	 <1184758229305-git-send-email-crquan@gmail.com>
	 <11847582511783-git-send-email-crquan@gmail.com>
	 <469E09FF.5050203@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	linux-kernel@vger.kernel.org
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:56535 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553AbXGRObj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 10:31:39 -0400
Received: by ug-out-1314.google.com with SMTP id j3so268214ugf
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2007 07:31:37 -0700 (PDT)
In-Reply-To: <469E09FF.5050203@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/18/07, Patrick McHardy <kaber@trash.net> wrote:
> This could be done in the patch moving it .. anyways,
What?

>
>
> Denis Cheng wrote:
> > +#ifdef CONFIG_PROC_FS
> > +static void *dev_mc_seq_start(struct seq_file *seq, loff_t *pos)
>
>
> If you're interested in doing more work, it would be nice to
> generalize the seq-file functions for unicast and multicast
> address lists and add /proc/net/dev_unicast or something like
> that.
Eh, there is already a dev_multicast file but lack of dev_unicast,
but is dev_unicast really useful?

>
> OTOH we could also export this using rtnetlink. The main reason
> why I didn't do that is that it can only be read, not changed,
> but this is also true for statistics etc. Any opinions on this?
how to do that?

>
>


-- 
Denis Cheng
Linux Application Developer

"One of my most productive days was throwing away 1000 lines of code."
 - Ken Thompson.
