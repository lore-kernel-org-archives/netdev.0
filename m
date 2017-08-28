From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 2/4] tc: m_ife: print IEEE ethertype format
Date: Mon, 28 Aug 2017 15:37:34 -0700
Message-ID: <20170828153734.4b32fa02@xeon-e3>
References: <20170828190738.26829-1-aring@mojatatu.com>
        <20170828190738.26829-3-aring@mojatatu.com>
        <ff74308c-2fe9-7c73-6215-8a269ea1be5e@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexander Aring <aring@mojatatu.com>, yotamg@mellanox.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34249 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751190AbdH1Whh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 18:37:37 -0400
Received: by mail-pf0-f172.google.com with SMTP id h75so5047154pfh.1
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 15:37:37 -0700 (PDT)
In-Reply-To: <ff74308c-2fe9-7c73-6215-8a269ea1be5e@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Aug 2017 18:18:04 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> Alex,
> 
> I think we should get rid of these fprintfs instead of fixing them.
> They were originally intended to be debug outputs.
> 
> cheers,
> jamal
> 
> On 17-08-28 03:07 PM, Alexander Aring wrote:
> > This patch uses the usually IEEE format to display an ethertype which is
> > 4-digits and every digit in upper case.
> > 
> > Signed-off-by: Alexander Aring <aring@mojatatu.com>
> > ---
> >   tc/m_ife.c | 2 +-
> >   1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/tc/m_ife.c b/tc/m_ife.c
> > index e05e2276..7b57130e 100644
> > --- a/tc/m_ife.c
> > +++ b/tc/m_ife.c
> > @@ -125,7 +125,7 @@ static int parse_ife(struct action_util *a, int *argc_p, char ***argv_p,
> >   			NEXT_ARG();
> >   			if (get_u16(&ife_type, *argv, 0))
> >   				invarg("ife type is invalid", *argv);
> > -			fprintf(stderr, "IFE type 0x%x\n", ife_type);
> > +			fprintf(stderr, "IFE type 0x%04X\n", ife_type);
> >   			user_type = 1;
> >   		} else if (matches(*argv, "dst") == 0) {
> >   			NEXT_ARG();
> >   
> 


For iproute commands the show output is supposed to match the corresponding set inputs.
