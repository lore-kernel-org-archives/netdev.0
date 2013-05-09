From: "Jongsung Kim" <neidhard.kim@lge.com>
Subject: RE: net: phy: realtek: add rtl8201f driver
Date: Thu, 9 May 2013 11:26:05 +0900
Message-ID: <008c01ce4c5c$8f572bc0$ae058340$@lge.com>
References: <201305081910.27203.neidhard.kim@lge.com> <20130508104119.GA24905@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <peppe.cavallaro@st.com>,
	<chohnstaedt@innominate.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "'Francois Romieu'" <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130508104119.GA24905@electric-eye.fr.zoreil.com>
Content-Language: ko
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> :
> Your patch contains both "remove unused #define" and "support new
hardware"
> parts. I am not sure that the former is adequate for submission until
net-next opens.

I see. Sorry for trying touching them even without comment. I won't touch
them.

> static void rtl8201f_page_select(struct phy_device *phydev, int page) ?

Okay. Looks better..

>> +	if(phy_driver_register(&rtl8201f_driver) < 0)
>         ^^ -> missing space.

What a shame!

> You may use an array of phy_driver for realtek_{init/exit}

Agreed.

--
Ueimor
