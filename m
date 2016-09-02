From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: e1000e on Thinkpad x60: gigabit not available due to "SmartSpeed"
Date: Fri, 2 Sep 2016 12:57:35 -0400
Message-ID: <20160902165735.GJ14311@csclub.uwaterloo.ca>
References: <20160901201408.GA5061@amd>
 <1472767093.3889.4.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Machek <pavel@ucw.cz>,
        kernel list <linux-kernel@vger.kernel.org>,
        jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org
To: Greg <gvrose8192@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1472767093.3889.4.camel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 01, 2016 at 02:58:13PM -0700, Greg wrote:
> On Thu, 2016-09-01 at 22:14 +0200, Pavel Machek wrote:
> > Hi!
> > 
> > I have trouble getting 1000mbit out of my ethernet card.
> > 
> > I tried direct connection between two PCs with different cables, and
> > no luck.
> > 
> > Today I tried connection to 1000mbit switch, and no luck, either. (Two
> > cables, one was cat6, both short).
> > 
> > My computer sees 1000mbit being advertised by the other side, but does
> > not advertise 1000mbit, "Link Speed was downgraded by SmartSpeed".
> 
> Check your cables?
> 
> https://vmxp.wordpress.com/2015/01/06/1gbe-intel-nic-throttled-to-100mbit-by-smartspeed/

Of course if it isn't the cable, then it could even be a broken pin in
the port.  As far as I can tell, anything that causes one of the 3rd
or 4th pairs of wires to not work will degrade to 100Mbit on just the
first 2 pairs of wires and give that message.  Some badly implemented
switches can also cause it of course.

-- 
Len Sorensen
