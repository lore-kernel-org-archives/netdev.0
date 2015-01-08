From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [patch iproute2 2/2] iplink: print out addrgenmode attribute
Date: Thu, 8 Jan 2015 09:13:08 +0200
Message-ID: <20150108071308.GA16389@angus-think.lan>
References: <1420561426-3118-1-git-send-email-jiri@resnulli.us>
 <1420561426-3118-2-git-send-email-jiri@resnulli.us>
 <20150107151036.2852e1be@urahara>
 <20150108070439.GB1860@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, thaller@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:48182 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752243AbbAHHXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 02:23:33 -0500
Received: by mail-la0-f41.google.com with SMTP id hv19so7696932lab.0
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 23:23:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150108070439.GB1860@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 08, 2015 at 08:04:39AM +0100, Jiri Pirko wrote:
> Thu, Jan 08, 2015 at 12:10:36AM CET, stephen@networkplumber.org wrote:
> >On Tue,  6 Jan 2015 17:23:46 +0100
> >Jiri Pirko <jiri@resnulli.us> wrote:
> >
> >> addrgenmode is currently write only by ip. So display this information
> >> if provided by kernel as well.
> >> 
> >> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> >
> >Patch does not apply to current iproute2 git
> 
> I made that against net-next branch. Which branch should I use for new
> features?
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

I am not sure if I am right, but seems to me that net-next should keep
features which depends on the next Linux headers version, and as I
understand these new headers are merged into net-next branch and after
into master. But I tried fix your patch on the master and it compiles
OK, so I assume that it can be based on master branch.

Regards,
