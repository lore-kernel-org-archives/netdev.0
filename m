From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: bonding vs 802.3ad/Cisco EtherChannel link agregation
Date: Fri, 13 Sep 2002 10:29:31 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3D81F64B.11182FB1@nortelnetworks.com>
References: <3D80DF4F.5B218F19@mc.com> <20020912.163447.131926830.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
List-Id: netdev.vger.kernel.org

"David S. Miller" wrote:
> 
> Bonding does not help with single stream performance.
> You have to have multiple apps generating multiple streams
> of data before you'll realize any improvement.
> Therefore netpipe is a bad test for what you're doing.

This has always confused me.  Why doesn't the bonding driver try and spread all the traffic over all
the links?  This would allow for a single stream to use the full aggregate bandwidth of all bonded
links.

Chris
