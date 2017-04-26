From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v8 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Wed, 26 Apr 2017 13:02:42 +0200
Message-ID: <20170426110241.GA28251@vergenet.net>
References: <1493121247-11863-1-git-send-email-jhs@emojatatu.com>
 <1493121247-11863-3-git-send-email-jhs@emojatatu.com>
 <20170425121338.GC1867@nanopsycho.orion>
 <5e54edd8-3943-6f09-490f-ff04b83077f6@mojatatu.com>
 <20170425160445.GD1867@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:35206 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2998875AbdDZLCp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 07:02:45 -0400
Received: by mail-wm0-f43.google.com with SMTP id w64so46863762wma.0
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 04:02:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170425160445.GD1867@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 06:04:45PM +0200, Jiri Pirko wrote:
> Tue, Apr 25, 2017 at 03:01:22PM CEST, jhs@mojatatu.com wrote:
> >On 17-04-25 08:13 AM, Jiri Pirko wrote:
> >> Tue, Apr 25, 2017 at 01:54:06PM CEST, jhs@mojatatu.com wrote:
> >
> >
> >[..]
> >
> >> > -#define TCAA_MAX 1
> >> > +/* tcamsg flags stored in attribute TCA_ROOT_FLAGS
> >> > + *
> >> > + * TCA_FLAG_LARGE_DUMP_ON user->kernel to request for larger than TCA_ACT_MAX_PRIO
> >> > + * actions in a dump. All dump responses will contain the number of actions
> >> > + * being dumped stored in for user app's consumption in TCA_ROOT_COUNT
> >> > + *
> >> > + */
> >> > +#define TCA_FLAG_LARGE_DUMP_ON		(1 << 0)
> >> 
> >> BIT (I think I mentioned this before)
> >> 
> >
> >You did - but i took it out about two submissions back (per cover
> >letter) because it is no part of UAPI today. I noticed devlink was
> >using it but they defined  their own variant.
> >So if i added this, iproute2 doesnt compile. I could fix iproute2
> >to move it somewhere to a common header then restore this.
> 
> So fix iproute2. It is always first kernel, then iproute2.

Perhaps I am missing the point or somehow misguided but I would expect that
if the UAPI uses BIT() it also provides BIT().

...
