From: Ion Badulescu <ion.badulescu@limegroup.com>
Subject: Re: Possible BUG in IPv4 TCP window handling, all recent 2.4.x/2.6.x
 kernels
Date: Fri, 2 Sep 2005 09:48:21 -0400 (EDT)
Message-ID: <Pine.LNX.4.61.0509020945550.6083@guppy.limebrokerage.com>
References: <Pine.LNX.4.61.0509011713240.6083@guppy.limebrokerage.com>
 <20050901.154300.118239765.davem@davemloft.net>
 <Pine.LNX.4.61.0509011845040.6083@guppy.limebrokerage.com>
 <2d02c76a84655d212634a91002b3eccd@psc.edu> <43184D79.6040009@mrv.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: John Heffner <jheffner@psc.edu>,
	Ion Badulescu <lists@limebrokerage.com>,
	"David S. Miller" <davem@davemloft.net>, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751316AbVIBNsl@vger.kernel.org>
To: Guillaume Autran <gautran@mrv.com>
In-Reply-To: <43184D79.6040009@mrv.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2 Sep 2005, Guillaume Autran wrote:

> I experienced the very same problem but with window size going all the way 
> down to just a few bytes (14 bytes). dump files available upon requests :)
> Ion, how were you able to reproduce the issue ? Can the same type of traffice 
> always reproduce the issue or is it more intermittent ?

I have no problem whatsoever reproducing it, at least with the kind of 
traffic I described. I had 4 flows like that running yesterday, and all 4 
had TCP window sizes smaller than 500 bytes on the receiver by mid-day.

-Ion
