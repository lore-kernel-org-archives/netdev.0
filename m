From: Joe Perches <joe@perches.com>
Subject: Re: [patch net-next v4 06/10] net: sched: introduce helpers to work
 with filter chains
Date: Wed, 17 May 2017 16:17:08 -0700
Message-ID: <1495063028.31562.24.camel@perches.com>
References: <20170517090803.4461-1-jiri@resnulli.us>
         <20170517090803.4461-7-jiri@resnulli.us>
         <ae02e4e8-3047-cd42-9c53-a2a38f8c28df@mojatatu.com>
         <20170517122528.GA9557@nanopsycho>
         <5270a876-6362-6c80-9911-8f929634edd1@mojatatu.com>
         <20170517124446.GB9557@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        xiyou.wangcong@gmail.com, dsa@cumulusnetworks.com,
        edumazet@google.com, stephen@networkplumber.org,
        daniel@iogearbox.net, alexander.h.duyck@intel.com,
        simon.horman@netronome.com, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0116.hostedemail.com ([216.40.44.116]:35580 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753011AbdEQXRS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 19:17:18 -0400
In-Reply-To: <20170517124446.GB9557@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-05-17 at 14:44 +0200, Jiri Pirko wrote:
> Wed, May 17, 2017 at 02:39:05PM CEST, jhs@mojatatu.com wrote:
> > On 17-05-17 08:25 AM, Jiri Pirko wrote:
> > > Wed, May 17, 2017 at 02:18:00PM CEST, jhs@mojatatu.com wrote:
> > > > On 17-05-17 05:07 AM, Jiri Pirko wrote:
> > > > > From: Jiri Pirko <jiri@mellanox.com>
> > > > > 
> > > > > Introduce struct tcf_chain object and set of helpers around it. Wraps up
> > > > > insertion, deletion and search in the filter chain.
> > > > > 
> > > > > Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> > > > > ---
> > > > 
> > > > [..]
> > > > > +
> > > > > +static void
> > > > > +tcf_chain_filter_chain_ptr_set(struct tcf_chain *chain,
> > > > > +			       struct tcf_proto __rcu **p_filter_chain)
> > > > > +
> > > > 
> > > > What are the rules for this? Common coding style is:
> > > > static void tcf_chain_filter_chain_ptr_set(struct tcf_chain *chain,
> > > >                                           struct tcf_proto ..
> > > 
> > > When this would not fit 80 cols (this case), you need to wrap the
> > > text in front of the function name. That is exacly what I did.
> > > 
> > 
> > That i understand.
> > The question is: what does scripture dictate on conflict?
> > Should a function signature always follow coding style and
> > allow for exceeding 80 chars or the 80 chars rules trumps?
> 
> Definitelly 80 chars rules trumps here.

Disagree.
80 columns is just a "strongly preferred" limit.

Clarity for a human reader trumps everything else.
