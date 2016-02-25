From: Hau <hau@realtek.com>
Subject: RE: [PATCH net v4] r8169:fix "rtl_counters_cond == 1 (loop: 1000, delay: 10)" log spam.
Date: Thu, 25 Feb 2016 05:48:58 +0000
Message-ID: <80377ECBC5453840BA8C7155328B5377013662F6@RTITMBSV03.realtek.com.tw>
References: <1456294722-3596-1-git-send-email-hau@realtek.com>
 <20160224215230.GA8013@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160224215230.GA8013@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Fine with me.
> 
> Is there any chance for the set of chipset dependent registers that are safe to
> be read when in D3 state to be documented ?
> 

I think except registers in PCI configuration, all other registers should be read in D0 state.

------Please consider the environment before printing this e-mail.
