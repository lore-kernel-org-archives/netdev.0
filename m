From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next-2.6] netfilter: remove deprecated config option
 NF_CT_ACCT
Date: Wed, 30 Jun 2010 15:11:54 +0200
Message-ID: <20100630131153.GB2582@psychotron.brq.redhat.com>
References: <20100629154507.GA5260@psychotron.brq.redhat.com>
 <4C2B3437.6000602@trash.net>
 <20100630124954.GA2582@psychotron.brq.redhat.com>
 <4C2B3E3D.7030804@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, ole@ans.pl
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54505 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751994Ab0F3NML (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jun 2010 09:12:11 -0400
Content-Disposition: inline
In-Reply-To: <4C2B3E3D.7030804@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jun 30, 2010 at 02:53:17PM CEST, kaber@trash.net wrote:
>Jiri Pirko wrote:
>>Wed, Jun 30, 2010 at 02:10:31PM CEST, kaber@trash.net wrote:
>>>Jiri Pirko wrote:
>>>>This patch removes deprecated config option NF_CT_ACCT. The default value is set
>>>>to 0 and warning message is put into connbytes_mt_init (connbytes selected
>>>>NF_CT_ACCT to enable it by default).
>>>Thanks, I already have a patch queued in nf-next for this.
>>>
>>
>>Oh, I see that: d70a011dbbaa6335a19deb63ec3eb613f48faafd
>
>a8756201ba4189bca3ee1a6ec4e290f467ee09ab also belongs to the removal.
>
>>
>>Apart your patch doesn't remove option from defconfigs (not sure if that's
>>necessary or not), your patch also do not print warning in connbytes_mt_init.
>>That would make connbytes silently non-functional. Therefore I think my patch is
>>better (more complete).
>
>The patch I have queued is automatically enabling accounting when
>the connbytes match is used and is printing a warning.

ok, that looks fine to me. What about those config options in def_config files?

