From: Willy Tarreau <w@1wt.eu>
Subject: Re: bnx2 dirver's firmware images
Date: Tue, 18 Sep 2007 23:30:25 +0200
Message-ID: <20070918213025.GF10199@1wt.eu>
References: <1190141114.9540.216.camel@dell> <20070918.112337.74737433.davem@davemloft.net> <1190145951.9540.230.camel@dell> <20070918.122150.124083496.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, vda.linux@googlemail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758722AbXIRVaq@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070918.122150.124083496.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 18, 2007 at 12:21:50PM -0700, David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Tue, 18 Sep 2007 13:05:51 -0700
> 
> > The bnx2 firmware changes quite frequently.  A new driver quite often
> > requires new firmware to work correctly.  Splitting them up makes things
> > difficult for the user.
> > 
> > The firmware in tg3 is a lot more mature and I don't expect it to
> > change.  I think tg3 is better suited for using request_firmware().
> 
> Like I said, I think neither should change and the driver should
> be fully functional when built statically into the kernel.

Michael, doesn't a functional-yet-suboptimal firmware exist ? I mean,
just the same principle as we all have kernels, boot CDs, statically
built tools, etc... which run everywhere. If you have such a beast,
maybe it would be a good start to have it in the kernel, and provide
the users with the ability to upgrade the firmware once the system
is able to do more complex things.

Just a thought...

Regards,
Willy
