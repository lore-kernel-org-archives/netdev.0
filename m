From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v2 net-next 13/13] ipv6: route: per route IP tunnel
 metadata via lightweight tunnel
Date: Wed, 19 Aug 2015 12:20:34 +0200
Message-ID: <20150819122034.5d904d8b@griffin>
References: <cover.1439978875.git.jbenc@redhat.com>
	<0694438feae2730b0bd3354b5e977bc9d6a5a192.1439978875.git.jbenc@redhat.com>
	<55D457B1.2080105@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41045 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751465AbbHSKUh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 06:20:37 -0400
In-Reply-To: <55D457B1.2080105@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Aug 2015 19:17:21 +0900, YOSHIFUJI Hideaki wrote:
> Jiri Benc wrote:
> > Allow specification of per route IP tunnel instructions also for IPv6.
> > This complements commit 3093fbe7ff4b ("route: Per route IP tunnel metadata
> > via lightweight tunnel").
> > 
> > Signed-off-by: Jiri Benc <jbenc@redhat.com>
> > ---
> >  include/uapi/linux/lwtunnel.h |  16 +++++++
> >  net/ipv4/ip_tunnel_core.c     | 102 ++++++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 118 insertions(+)
> > 
> > diff --git a/include/uapi/linux/lwtunnel.h b/include/uapi/linux/lwtunnel.h
> > index aa84ca396bcb..32a149571417 100644
> > --- a/include/uapi/linux/lwtunnel.h
> > +++ b/include/uapi/linux/lwtunnel.h
> > @@ -7,6 +7,7 @@ enum lwtunnel_encap_types {
> >  	LWTUNNEL_ENCAP_NONE,
> >  	LWTUNNEL_ENCAP_MPLS,
> >  	LWTUNNEL_ENCAP_IP,
> > +	LWTUNNEL_ENCAP_IP6,
> >  	LWTUNNEL_ENCAP_ILA,
> >  	__LWTUNNEL_ENCAP_MAX,
> >  };
> 
> Please do not add new one in the middle of enums.

You're right generally. But this one should be okay and I did this
deliberately: the patch adding LWTUNNEL_ENCAP_ILA was merged two days
ago, is in net-next only, is not used by anything in user space yet.
And I think it's better to have LWTUNNEL_ENCAP_IP and
LWTUNNEL_ENCAP_IP6 without anything in between.

Thanks,

 Jiri

-- 
Jiri Benc
