From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 0/3] net: Linn Ethernet Packet Sniffer driver
Date: Wed, 25 Feb 2015 15:21:30 +0100
Message-ID: <20150225142130.GA7703@localhost.localdomain>
References: <cover.1424181053.git.stathis.voukelatos@linn.co.uk>
 <20150218210830.GA7778@localhost.localdomain>
 <54EAF4D4.4090505@linn.co.uk>
 <20150225095056.GB4293@localhost.localdomain>
 <54EDA997.1080005@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	netdev@vger.kernel.org, abrestic@chromium.org
To: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54EDA997.1080005@linn.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 25, 2015 at 10:53:11AM +0000, Stathis Voukelatos wrote:
> On 25/02/15 09:50, Richard Cochran wrote:
> >
> >The Linux kernel already fully supports this kind of application via
> >the SIOCSHWTSTAMP, SO_TIMESTAMPING, and PHC mechanisms.  We certainly
> >don't need another another interface just for someone's warped
> >hardware design.
> >
> >I suggest that you find a way to make your HW work within the existing
> >frame work.
> 
> The driver already uses that framework for returning timestamps to
> user space. It does not introduce any new interface.

No, it only abuses the interfaces that we already have.  The time
stamp handling is not "within the existing frame work" by any means.
However, there is a way to integrate this hardware properly...

> The H/W could not support that:

With these new explanations, now I understand the code and how this is
supposed to work.

I'll put further comments in a reply to your newer series.

Thanks,
Richard
