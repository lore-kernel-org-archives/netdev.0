From: "Jongsung Kim" <neidhard.kim@lge.com>
Subject: RE: net: phy: realtek: add rtl8201f driver
Date: Thu, 9 May 2013 11:35:03 +0900
Message-ID: <008d01ce4c5d$cfd36410$6f7a2c30$@lge.com>
References: <201305081910.27203.neidhard.kim@lge.com> <518A7284.4000504@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <peppe.cavallaro@st.com>,
	<chohnstaedt@innominate.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "'Sergei Shtylyov'" <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <518A7284.4000504@cogentembedded.com>
Content-Language: ko
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> :
>     Removal of unused #define's is a matter of a separate cleanup patch...

Sorry. I won't touch them.

>> +static int rtl8201f_ack_interrupt(struct phy_device *phydev) {
>> +	int err;
>> +
>> +	err = phy_read(phydev, RTL8201F_ISR);
>
>    This could be an initializer and so make the function shorter.
>

Agreed. I just thought it's better to make it similar to the
rtl821x_ack_interrupt. Then, may I make shorter the rtl821x_ack_interrupt as
well as rtl8201f_ack_interrupt?

>
>     You haven't run this patch thru scripts/checkpatch.pl -- there should
be a space between *if* and (.
>

Sorry.. what a mistake..
