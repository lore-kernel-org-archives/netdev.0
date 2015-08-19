From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v2 net-next 13/13] ipv6: route: per route IP tunnel
 metadata via lightweight tunnel
Date: Wed, 19 Aug 2015 12:31:51 +0200
Message-ID: <20150819123151.3802e8f3@griffin>
References: <cover.1439978875.git.jbenc@redhat.com>
	<0694438feae2730b0bd3354b5e977bc9d6a5a192.1439978875.git.jbenc@redhat.com>
	<55D457B1.2080105@miraclelinux.com>
	<20150819122034.5d904d8b@griffin>
	<55D45A0A.7010100@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46319 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751516AbbHSKby (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 06:31:54 -0400
In-Reply-To: <55D45A0A.7010100@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Aug 2015 19:27:22 +0900, YOSHIFUJI Hideaki wrote:
> > You're right generally. But this one should be okay and I did this
> > deliberately: the patch adding LWTUNNEL_ENCAP_ILA was merged two days
> > ago, is in net-next only, is not used by anything in user space yet.
> > And I think it's better to have LWTUNNEL_ENCAP_IP and
> > LWTUNNEL_ENCAP_IP6 without anything in between.
> 
> I do think you should have some descriptions.

Sorry, I meant to put this into the description but forget to add it
after the rebase on top of ILA (as the patchset conflicted with the ILA
work and was developed in parallel).

Are you okay with inserting LWTUNNEL_ENCAP_IP6 before
LWTUNNEL_ENCAP_ILA? If so, I'll resend with the explanation added.

Thanks,

 Jiri

-- 
Jiri Benc
