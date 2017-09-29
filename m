From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next RFC 0/9] net: dsa: PTP timestamping for mv88e6xxx
Date: Fri, 29 Sep 2017 05:43:23 -0400
Message-ID: <20170929094323.cwh2ubv4odknlyot@localhost>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Erik Hons <erik.hons@ni.com>
To: Brandon Streiff <brandon.streiff@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brandon,

On Thu, Sep 28, 2017 at 10:25:32AM -0500, Brandon Streiff wrote:
> - Patch #2: We expose the switch time as a PTP clock but don't support
>   adjustment (max_adj=0).

The driver should implement a cyclecounter/timecounter.

> Our platform adjusted a systemwide oscillator
>   from userspace, so we didn't need adjustment at this layer, but other
>   PTP clock drivers support this and we probably should too.

We don't currently have any way to support this kind of HW or anything
like an external VCO.  I would like to find a way to do this, but that
is a different kettle of fish as it might require changes in the PHC
subsystem.  For this driver, I think we should get it merged using the
cyclecounter/timecounter (as that will benefit lots of users) and
worry about the external oscillator later.
 
> Feedback is appreciated.

I happy to see this series.  I just finished porting an out-of-tree
PHC driver for the Marvell mv88e635x, and I want to mainline it, but I
also have a few uglies.

Unfortunately I am in the middle of a move right now, and so my review
of this series might have to wait a bit.  However, I am looking
forward to comparing notes, and then getting this support in.

Thanks,
Richard
