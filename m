From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: Re: [PATCH -v3 16/23] drivers/net: rename random32() to prandom_u32()
Date: Tue, 5 Mar 2013 06:53:12 +0900
Message-ID: <CAC5umyjMvMW8ZZ1JFJcZVYo7PiUkG+dVgUNQ3bd87SW_6LnYqw@mail.gmail.com>
References: <1362401911-14074-1-git-send-email-akinobu.mita@gmail.com>
	<1362401911-14074-17-git-send-email-akinobu.mita@gmail.com>
	<5134A37D.9000704@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	Thomas Sailer <t.sailer@alumni.ethz.ch>,
	Jean-Paul Roubelat <jpr@f6fbb.org>,
	Bing Zhao <bzhao@marvell.com>,
	Brett Rudley <brudley@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	brcm80211-dev-list@broadcom.com, netdev <netdev@vger.kernel.org>,
	linux-hams@vger.kernel.org, linux-wireless@vger.kernel.org
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <5134A37D.9000704@broadcom.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2013/3/4 Arend van Spriel <arend@broadcom.com>
>>
>> @@ -1118,7 +1118,7 @@ static void brcmf_p2p_afx_handler(struct work_struct *work)
>>         if (afx_hdl->is_listen&&  afx_hdl->my_listen_chan)
>>
>>                 /* 100ms ~ 300ms */
>>                 err = brcmf_p2p_discover_listen(p2p, afx_hdl->my_listen_chan,
>> -                                               100 * (1 + (random32() % 3)));
>> +                                       100 * (1 + (prandom_u32() % 3)));
>
>
> Seems like indentation is wrong now. Please retain the alignment.

OK, I'll fix it.
