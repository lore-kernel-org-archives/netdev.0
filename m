From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [ovs-dev] [PATCH net-next 1/2] openvswitch: add tunnel protocol
 to sw_flow_key
Date: Wed, 30 Sep 2015 09:14:09 +0200
Message-ID: <20150930091409.33d4b7ae@griffin>
References: <cover.1443548447.git.jbenc@redhat.com>
	<428cee4cb7e04cfea5bef90b37d257562ea78a83.1443548447.git.jbenc@redhat.com>
	<CAEP_g=_5EhyYeSNvitYSbNX9G52Kt=R6ruNz4V0uJK8sxPyYWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60622 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753746AbbI3HOM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 03:14:12 -0400
In-Reply-To: <CAEP_g=_5EhyYeSNvitYSbNX9G52Kt=R6ruNz4V0uJK8sxPyYWQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Sep 2015 19:08:44 -0700, Jesse Gross wrote:
> On Tue, Sep 29, 2015 at 10:52 AM, Jiri Benc <jbenc@redhat.com> wrote:
> > diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> > index 5c030a4d7338..03ba070c3256 100644
> > --- a/net/openvswitch/flow_netlink.c
> > +++ b/net/openvswitch/flow_netlink.c
> > @@ -643,6 +643,7 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
> >         }
> >
> >         SW_FLOW_KEY_PUT(match, tun_key.tun_flags, tun_flags, is_mask);
> > +       SW_FLOW_KEY_PUT(match, tun_proto, AF_INET, is_mask);
> 
> I don't think this is right in the case of the mask. It will cause the
> the mask to be the value AF_INET - instead you want to set the mask to
> be 0xff.

I think you're right, this is a special case. I'll fix it.

Thanks,

 Jiri

-- 
Jiri Benc
