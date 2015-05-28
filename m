From: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the RDMA-CM
Date: Thu, 28 May 2015 22:05:05 +0300
Message-ID: <CAJ3xEMh2T5-56rFxWVdct2uAZYW1ZrKivWfS45V-mvhAfwyGaA@mail.gmail.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
	<1432647280.28905.107.camel@redhat.com>
	<55671309.6080303@mellanox.com>
	<1432822057.114391.26.camel@redhat.com>
	<55674077.5040707@mellanox.com>
	<20150528174337.GA10448@obsidianresearch.com>
	<1432837360.114391.35.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1432837360.114391.35.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, May 28, 2015 at 9:22 PM, Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

>> I don't think that is what Doug said.

> Indeed.  There is no need to scrap things, but if the design as it
> stands, and the intended means of creating objects for use in
> containers, is going to result in an unworkable network, then we have to
> re-evaluate how the container constructs are created, and that then has
> possible consequences for how we would get from an incoming packet to
> the proper container.

To be precise, do we agree that the issue here isn't "in the design as
it stands" but rather in a problem we found in the intended way of
assigning IP addresses through DHCP for the containers?

> I'm not trying to stop the "support train" here, but at the same time,
> if the train is headed for a bridge that's out....

So what's your concrete saying here? where should we go from here?

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
