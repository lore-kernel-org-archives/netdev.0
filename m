From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] net: emac: emac gigabit ethernet controller driver
Date: Wed, 9 Dec 2015 22:04:03 -0600
Message-ID: <5668F9B3.3090708@codeaurora.org>
References: <1449529094-10922-1-git-send-email-gavidov@codeaurora.org>
 <CAOZdJXXQKMrOJpm3XJmX5ZULEoOZqS12u5FWKdcxfUm+LnGbww@mail.gmail.com>
 <20151209172645.5e6ab040@gavidov-lnx.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, sdharia@codeaurora.org,
	linux-arm-msm@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
	vikrams@codeaurora.org,
	Shanker Donthineni <shankerd@codeaurora.org>
To: Gilad Avidov <gavidov@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151209172645.5e6ab040@gavidov-lnx.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gilad Avidov wrote:
> pointer math on void* ?
> what is the size of void ?

I'm talking about adding and subtracting pointer values, so

u32 pkt_len =((void *)ip_hdr(skb) - skb->data)

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
