From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 0/3] export device physical port id to
 userspace
Date: Sun, 21 Jul 2013 09:26:47 +0200
Message-ID: <20130721072647.GB1944@minipsycho.orion>
References: <1374342834-10814-1-git-send-email-jiri@resnulli.us>
 <CAJZOPZ+T=qZ3qsE-h3j_UTFi3byFQ4xKzLKN0prq83z6ZqkPmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org, Narendra_K@dell.com,
	bhutchings@solarflare.com, john.r.fastabend@intel.com
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:53697 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753445Ab3GUH0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 03:26:51 -0400
Received: by mail-ea0-f172.google.com with SMTP id q10so3221828eaj.3
        for <netdev@vger.kernel.org>; Sun, 21 Jul 2013 00:26:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJZOPZ+T=qZ3qsE-h3j_UTFi3byFQ4xKzLKN0prq83z6ZqkPmA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Jul 21, 2013 at 07:59:54AM CEST, or.gerlitz@gmail.com wrote:
>On Sat, Jul 20, 2013 at 8:53 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> This patchset is based on patch by Narendra_K@Dell.com
>
>Hi Jiri,
>
>Just a small note to make we're not running (at least not foo fast...)
>here... the patch you mentioned

This patchset replaces the mentioned patch. So there's no dependency.

>is still not finalized I think. At least, as I mentioned there, lets
>see it allows to modify
>the current drivers that make use of the dev_id field to denote port number to
>the new scheme,  before we build the 2nd floor of the building.

Just implement ndo_get_phys_port_id for those drivers, that's all needed
(of course after this patchset is applied)

>
>Or.
