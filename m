From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [patch net-next RFC 0/6] Introduce devlink interface and first
 drivers to use it
Date: Fri, 5 Feb 2016 15:29:36 +0100
Message-ID: <20160205152936.63863d27@redhat.com>
References: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
	<20160203143133.1b70bcb5@redhat.com>
	<20160203133356.GA2219@nanopsycho.orion>
	<56B219FA.7080208@iogearbox.net>
	<9B0331B6EBBD0E4684FBFAEDA55776F92CB6D2ED@HASMSX110.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Jiri Pirko <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"idosch@mellanox.com" <idosch@mellanox.com>,
	"eladr@mellanox.com" <eladr@mellanox.com>,
	"yotamg@mellanox.com" <yotamg@mellanox.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"yishaih@mellanox.com" <yishaih@mellanox.com>,
	"dledford@redhat.com" <dledford@redhat.com>,
	"Hefty, Sean" <sean.hefty@intel.com>,
	"hal.rosenstock@gmail.com" <hal.rosenstock@gmail.com>,
	"eugenia@mellanox.com" <eugenia@mellanox.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"nikolay@cumulusnetworks.com" <nikolay@cumulusnetworks.com>,
	"hadarh@mellanox.com" <hadarh@mellanox.com>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@
To: "Rosen, Rami" <rami.rosen@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44692 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750850AbcBEO3q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Feb 2016 09:29:46 -0500
In-Reply-To: <9B0331B6EBBD0E4684FBFAEDA55776F92CB6D2ED@HASMSX110.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 4 Feb 2016 19:01:55 +0000
"Rosen, Rami" <rami.rosen@intel.com> wrote:

> Hi,
> 
> >Btw, if you add this tool into iproute2 (which would be preferred), >then
> >probably dl should be ok (and easier retrievable in that relation).  
> 
> +1.
> 
> This tool, which uses netlink messages, seems a natural candidate for iproute2.
>  
> And also apart from "ip", we have also another short command in
> iproute2, namely "tc", which is yet another justification for using
> the short form with "dl".

I agree that integration into iproute2 is a good idea.

I strongly disagree on introducing such a short command name. Today we
live in a world where you google for usage examples... the ip and tc
commands origin for another time, and IMHO their short names have hurt
them not getting broad usage.  Especially it have been difficult to get
people to really adopt "ip", which is also worst search term in the
Internet today...

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
