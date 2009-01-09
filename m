From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.28-git8: tg3 doesn't work due to firmware not loading
 (-git7 is ok)
Date: Fri, 09 Jan 2009 14:04:22 -0800 (PST)
Message-ID: <20090109.140422.60087297.davem@davemloft.net>
References: <5a4c581d0901081233y6b546167sbe3ed9f2ea37f1f9@mail.gmail.com>
	<20090108.125331.03608787.davem@davemloft.net>
	<5a4c581d0901090930j5d4760b0x730b5609fa2b5614@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jaswinderlinux@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, dwmw2@infradead.org
To: alessandro.suardi@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759182AbZAIWEp@vger.kernel.org>
In-Reply-To: <5a4c581d0901090930j5d4760b0x730b5609fa2b5614@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Alessandro Suardi" <alessandro.suardi@gmail.com>
Date: Fri, 9 Jan 2009 18:30:40 +0100

> Clearly the requirement changed in -git8, AFAICS.

Because -git8 is where the firmware requirement got added.

If you build the TG3 driver statically into your kernel,
the only way to get the firmware properly loaded is to
enable that CONFIG_FIRMWARE_IN_KERNEL option.

Your filesystem isn't mounted when the driver initializes
in that case, therefore there is no way to get at the
firwware that might be present there.
