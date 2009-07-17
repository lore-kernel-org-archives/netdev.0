From: Wolfgang Denk <wd@denx.de>
Subject: Re: [PATCH 2/2 v2] MPC52xx FEC: be more conservative when setting MII_SPEED register
Date: Fri, 17 Jul 2009 14:25:33 +0200
Message-ID: <20090717122533.09431832E416@gemini.denx.de>
References: <1247671133-12148-1-git-send-email-wd@denx.de> <1247780546-4426-2-git-send-email-wd@denx.de> <fa686aa40907161548n1658afaei8dce2d893222019c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linuxppc-dev@ozlabs.org, Kumar Gala <galak@kernel.crashing.org>,
	netdev@vger.kernel.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:50758 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934509AbZGQMZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 08:25:35 -0400
In-reply-to: <fa686aa40907161548n1658afaei8dce2d893222019c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Grant Likely,

In message <fa686aa40907161548n1658afaei8dce2d893222019c@mail.gmail.com> you wrote:
> 
> Mostly good.  One comment below.  When it's resolved, feel free to add
> my acked-by line.  Thanks for getting this done.
...
> Just thought of something.  If it cannot find the clock, then wouldn't
> it be better to just use the maximum divider and print a warning
> instead of bailing completely?  This goes for the other patch as well.

Will change this for both patches. Thanks.

Best regards,

Wolfgang Denk

-- 
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: (+49)-8142-66989-10 Fax: (+49)-8142-66989-80 Email: wd@denx.de
Program maintenance is an entropy-increasing process,  and  even  its
most skilfull execution only delays the subsidence of the system into
unfixable obsolescence.       - Fred Brooks, "The Mythical Man Month"
