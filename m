From: Borislav Petkov <bp@alien8.de>
Subject: Re: 3.16-rc6+: r8169 fresh new irq lock inversion
Date: Thu, 24 Jul 2014 11:05:10 +0200
Message-ID: <20140724090510.GD19239@pd.tnic>
References: <20140722081840.GA6462@pd.tnic>
 <0835B3720019904CB8F7AA43166CEEB2510016@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: nic_swsd <nic_swsd@realtek.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2510016@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 24, 2014 at 09:01:27AM +0000, Hayes Wang wrote:
> I have no idea about why you see the messages.  I don't think
> the patches which submitted previously for r8169.c  would cause
> the problem. Although I have submitted some patches about IPv6,
> the hw checksum should be off by default. That is, the behavior
> should be the same with the previous one.

Yeah, the culprit might be somewhere else, follow this thread:

https://lkml.kernel.org/r/20140723095327.GA23131@pd.tnic

Thanks for taking a look anyway though.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
