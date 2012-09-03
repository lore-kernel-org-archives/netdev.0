From: Renato Westphal <renatowestphal@gmail.com>
Subject: Re: [PATCH RFC 0/2] Interface for TCP Metrics
Date: Mon, 3 Sep 2012 09:11:07 -0300
Message-ID: <CAChaegkatQcHQ3axhcfDQN-3pQLRaq=+NC7QOu4aGNduDO63oQ@mail.gmail.com>
References: <1345734105-28328-1-git-send-email-ja@ssi.bg>
	<20120823082235.27c057f6@nehalam.linuxnetplumber.net>
	<alpine.LFD.2.00.1208231908380.28424@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:34498 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752724Ab2ICMLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2012 08:11:09 -0400
Received: by vcbfk26 with SMTP id fk26so5367159vcb.19
        for <netdev@vger.kernel.org>; Mon, 03 Sep 2012 05:11:07 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.00.1208231908380.28424@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>         BTW, I noticed that the GENL part in iproute is
> not separated in common place. Should we create common
> place for functions like genl_ctrl_resolve_family and
> genl_parse_getfamily ?

I think it would be nice to extend libnetlink or create something like
'libgenetlink' with these GENL facilities you created. The tendency is
to increase the number of genetlink users over time, so it seems to
make sense to provide some basic infrastructure for these new users.
Every genetlink application needs to resolve family names and possibly
multicast group names, so I think putting these basic facilities in
common place will help to reduce code duplication in the future.

-- 
Renato Westphal
