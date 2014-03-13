From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 2/2] net: Implement SO_PEERCGROUP
Date: Thu, 13 Mar 2014 14:02:24 -0400
Message-ID: <20140313180224.GJ18914@redhat.com>
References: <1394657163-7472-3-git-send-email-vgoyal@redhat.com>
 <5320CAEC.6030008@amacapital.net>
 <CALCETrUTjN=XKwnO62P9roZtLLuk7_9Oi17Mj_Aa2ZFtZc1gVA@mail.gmail.com>
 <1394658983.32465.203.camel@willson.li.ssimo.org>
 <CALCETrU29CpcK4dVRD45BGOD7AVEudADiFxOgFgKWkpFzw07eg@mail.gmail.com>
 <1394673476.32465.215.camel@willson.li.ssimo.org>
 <CALCETrWbCuKfV4zMkZajDOGhGkKduW0C2L7uHv=vtvqhVeAc6w@mail.gmail.com>
 <1394675038.32465.223.camel@willson.li.ssimo.org>
 <CALCETrV7GE0YL1sDDqTUV81rWL9zk2vTR1-VLkR7CfTA-FSrgw@mail.gmail.com>
 <1394733077.32465.243.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@amacapital.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	cgroups@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	jkaluza@redhat.com, lpoetter@redhat.com, kay@redhat.com
To: Simo Sorce <ssorce@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25633 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754439AbaCMSC2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Mar 2014 14:02:28 -0400
Content-Disposition: inline
In-Reply-To: <1394733077.32465.243.camel@willson.li.ssimo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 13, 2014 at 01:51:17PM -0400, Simo Sorce wrote:

[..]
> > 1. Fix Docker to use user namespaces and use the uid of the requesting
> > process via SCM_CREDENTIALS.
> 
> This is not practical, I have no control on what UIDs will be used
> within a container,

I guess uid to container mapping has to be managed by somebody, say systemd.
Then there systemd should export an API to query the container a uid is
mapped into. So that should not be the real problem.

> and IIRC user namespaces have severe limitations
> that may make them unusable in some situations. Forcing the use of user
> namespaces on docker to satisfy my use case is not in my power.

I think that's the real practical problem. Adoption of user name space.

Thanks
Vivek
