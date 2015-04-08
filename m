From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v2 net-next 2/2] tc: make ingress and egress qdiscs consistent
Date: Wed, 08 Apr 2015 08:58:57 -0400
Message-ID: <55252611.3040109@mojatatu.com>
References: <1428455025-5945-1-git-send-email-ast@plumgrid.com> <1428455025-5945-2-git-send-email-ast@plumgrid.com> <20150407.223549.335906307265617841.davem@davemloft.net> <55249EFA.5040405@plumgrid.com> <5524B339.1070403@plumgrid.com> <5524E878.7070803@iogearbox.net> <20150408090520.GA2057@nanopsycho.orion> <552508E8.5050203@iogearbox.net> <55250D92.6030702@iogearbox.net> <55251556.4040900@mojatatu.com> <55251F9F.2050508@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	tgraf@suug.ch
To: Daniel Borkmann <daniel@iogearbox.net>,
	Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:33528 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753070AbbDHM7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 08:59:05 -0400
Received: by iebmp1 with SMTP id mp1so72871447ieb.0
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 05:59:05 -0700 (PDT)
In-Reply-To: <55251F9F.2050508@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/15 08:31, Daniel Borkmann wrote:

> So aside from the ifb dev, the only guys caring about AT_INGRESS
> and AT_EGRESS is netem and act_mirred.

And the IFE action (which i havent submitted because Dave wanted me to
see if i can get an IEEE ethertype allocated first).
Essentially - this is an important optimization. If some action is
interested to find where it is connected the information is there.
But we dont want to impose on every action/classifier to be part of
this activity.

>That means the tc's cls_u32
> sample selectors a la ip, ip6, udp, tcp, icmp don't work on ingress
> either,so in u32 speak you would need to do that by hand, but that
> doesn't work as you don't have the Ethernet type context available.
> Am I missing something? :)

u32 works fine. I am sure i have tests which run these on both
in/egress.

cheers,
jamal
