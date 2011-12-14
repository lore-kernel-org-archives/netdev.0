From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/1] r8169.c correct MSIEnable register offset
Date: Wed, 14 Dec 2011 22:37:13 +0100
Message-ID: <20111214213713.GA2907@electric-eye.fr.zoreil.com>
References: <CABJLtPHWfRLcbzDFR0ZXe4da3jv04eDZL2CabF1FTcaadoy0xQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang <hayeswang@realtek.com>, linux-kernel@vger.kernel.org,
	nic_swsd@realtek.com, netdev@vger.kernel.org
To: Su Kang Yin <cantona@cantona.no-ip.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CABJLtPHWfRLcbzDFR0ZXe4da3jv04eDZL2CabF1FTcaadoy0xQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Su Kang Yin <cantona@cantona.no-ip.org> :
> correct MSIEnable (bit 5) register to Config1 (offset 0x52) instead of
> Config2 (offset 0x53)

I wonder where the inspiration for the MSIEnable bit came from.
It looks like something was confused with the Message Control word
in PCI space.

Imho you can simply remove it altogether.

-- 
Ueimor
