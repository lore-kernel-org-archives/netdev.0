From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next RFC 4/9] net: dsa: mv88e6xxx: add support for
 event capture
Date: Mon, 9 Oct 2017 21:53:29 -0400
Message-ID: <20171010015329.b5yvspofytay7osx@localhost>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
 <1506612341-18061-5-git-send-email-brandon.streiff@ni.com>
 <20171008150634.hb7nxwbbmi5xff7m@localhost>
 <CAEYbN3TpMVPVapmLNCPj69pxP9b_1y8VizS3XvccskcWOrpwEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brandon Streiff <brandon.streiff@ni.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Erik Hons <erik.hons@ni.com>
To: Levi Pearson <levipearson@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAEYbN3TpMVPVapmLNCPj69pxP9b_1y8VizS3XvccskcWOrpwEw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 09, 2017 at 04:08:50PM -0600, Levi Pearson wrote:
> Another issue related to this is that while the free-running counter
> in the hardware can't be easily adjusted, the periodic event generator
> *can* be finely adjusted (via picosecond and sub-picosecond
> accumulators) to correct for drift between the local clock and the PTP
> grandmaster time. So to be semantically correct, this needs to be both
> started at the right time *and* it needs to have the periodic
> corrections made so that the fine correction parameters in the
> hardware keep it adjusted to be synchronous with PTP grandmaster time.

So if the accumulators are safe to adjust on the fly, then the
adjfine() method will have to program them with every adjustment.

Thanks,
Richard
