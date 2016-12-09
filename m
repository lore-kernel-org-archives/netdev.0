From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC PATCH net-next v3 1/2] macb: Add 1588 support in Cadence
 GEM.
Date: Fri, 9 Dec 2016 09:57:52 +0100
Message-ID: <20161209085752.GB16009@localhost.localdomain>
References: <1481134912-2243-1-git-send-email-andrei.pistirica@microchip.com>
 <20161207193908.GA13062@netboy>
 <20161207210416.GA27622@netboy>
 <07C910AB6AC6C345A093D5A08F5AF568CB74AF28@CHN-SV-EXMX03.mchp-main.com>
 <CAFcVECJutEu2=POtAU=jX6E3-ZHsLXpOMMw+UJ0hcQgZ0n4ZVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrei Pistirica <Andrei.Pistirica@microchip.com>,
        netdev@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        David Miller <davem@davemloft.net>,
        Nicolas Ferre <nicolas.ferre@atmel.com>,
        Harini Katakam <harini.katakam@xilinx.com>,
        Punnaiah Choudary Kalluri <punnaia@xilinx.com>,
        "michals@xilinx.com" <michals@xilinx.com>,
        Anirudha Sarangi <anirudh@xilinx.com>,
        Boris Brezillon <boris.brezillon@free-electrons.com>,
        alexandre.belloni@free-electrons.com, tbultel@pixelsurmer.com,
        Rafal Ozieblo <rafalo@cadence.com>
To: Harini Katakam <harinikatakamlinux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAFcVECJutEu2=POtAU=jX6E3-ZHsLXpOMMw+UJ0hcQgZ0n4ZVA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 09, 2016 at 11:07:23AM +0530, Harini Katakam wrote:
> I'm afraid I don't get why we are choosing the most limited max adj..
> Sorry if I'm missing something - could you please help me understand?

This max_adj is only important when the local clock offset is large
and user space chooses not to step the time value.  In that case, user
space will want to run the clock as fast (or as slow) as possible in
order to catch up with the remote clock.

The driver must provide a max_adj that is always safe for user space
to apply via the clock_adjtime() system call.

HTH,
Richard
