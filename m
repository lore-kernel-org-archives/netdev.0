From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2 dirver's firmware images
Date: Tue, 18 Sep 2007 13:05:51 -0700
Message-ID: <1190145951.9540.230.camel@dell>
References: <200709181823.26429.vda.linux@googlemail.com>
 <1190141114.9540.216.camel@dell>
 <20070918.112337.74737433.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: vda.linux@googlemail.com, linux-kernel@vger.kernel.org,
	"netdev" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757997AbXIRTIT@vger.kernel.org>
In-Reply-To: <20070918.112337.74737433.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-09-18 at 11:23 -0700, David Miller wrote:

> I don't like it because it means people have to setup full initrd's
> in order to do network booting with such network cards.
> 
> But the days of my opinion mattering on that issue are long gone,
> the momentum is just too greatly behind using request_firmware()
> across the board, so there is no reason for bnx2 to be any different.
> 

The bnx2 firmware changes quite frequently.  A new driver quite often
requires new firmware to work correctly.  Splitting them up makes things
difficult for the user.

The firmware in tg3 is a lot more mature and I don't expect it to
change.  I think tg3 is better suited for using request_firmware().
