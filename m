From: Cacophonix <cacophonix@yahoo.com>
Subject: Re: bonding vs 802.3ad/Cisco EtherChannel link agregation
Date: Fri, 13 Sep 2002 15:22:13 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020913222213.69396.qmail@web14006.mail.yahoo.com>
References: <3D81F64B.11182FB1@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Friesen <cfriesen@nortelnetworks.com>
In-Reply-To: <3D81F64B.11182FB1@nortelnetworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--- Chris Friesen <cfriesen@nortelnetworks.com> wrote:
> "David S. Miller" wrote:
> > 
> > Bonding does not help with single stream performance.
> > You have to have multiple apps generating multiple streams
> > of data before you'll realize any improvement.
> > Therefore netpipe is a bad test for what you're doing.
> 
> This has always confused me.  Why doesn't the bonding driver try and spread all the
> traffic over all
> the links?  This would allow for a single stream to use the full aggregate bandwidth of
> all bonded
> links.

Because then you risk heavy packet reordering within an individual flow,
which can be detrimental in some cases.
--karthik


__________________________________________________
Do you Yahoo!?
Yahoo! News - Today's headlines
http://news.yahoo.com
