From: yuan linyu <cugyly@163.com>
Subject: Re: [PATCH] net: remove member 'max' of struct scm_fp_list
Date: Sat, 11 Feb 2017 10:04:22 +0800
Message-ID: <1486778662.2554.2.camel@163.com>
References: <1486728673-19466-1-git-send-email-cugyly@163.com>
         <20170210.102543.2139355880844380775.davem@davemloft.net>
Reply-To: cugyly@163.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Linyu.Yuan@alcatel-sbell.com.cn
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-18.163.com ([220.181.12.18]:60689 "EHLO m12-18.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753317AbdBKCEd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 10 Feb 2017 21:04:33 -0500
In-Reply-To: <20170210.102543.2139355880844380775.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 五, 2017-02-10 at 10:25 -0500, David Miller wrote:
> From: yuan linyu <cugyly@163.com>
> Date: Fri, 10 Feb 2017 20:11:13 +0800
> 
> > From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> > 
> > SCM_MAX_FD can fully replace it.
> > 
> > Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> 
> I don't think so:
> 
> > @@ -341,7 +332,6 @@ struct scm_fp_list *scm_fp_dup(struct scm_fp_list *fpl)
> >       if (new_fpl) {
> >               for (i = 0; i < fpl->count; i++)
> >                       get_file(fpl->fp[i]);
> > -             new_fpl->max = new_fpl->count;
> >               new_fpl->user = get_uid(fpl->user);
> 
> It's not set the SCM_MAX_FD here, it's set to whatever fpl->count is.
> 
> In other words, your patch breaks things.
maybe it's not good to "SCM_MAX_FD can fully replace it".
actually 'max' field is useless.'count' field is enough.
 
