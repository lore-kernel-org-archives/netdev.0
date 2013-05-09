From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: net: phy: realtek: add rtl8201f driver
Date: Thu, 09 May 2013 20:58:55 +0400
Message-ID: <518BD5CF.8040502@cogentembedded.com>
References: <201305081910.27203.neidhard.kim@lge.com> <518A7284.4000504@cogentembedded.com> <008d01ce4c5d$cfd36410$6f7a2c30$@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, peppe.cavallaro@st.com,
	chohnstaedt@innominate.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jongsung Kim <neidhard.kim@lge.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:53791 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821Ab3EIQ64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 12:58:56 -0400
Received: by mail-lb0-f173.google.com with SMTP id 10so772729lbf.18
        for <netdev@vger.kernel.org>; Thu, 09 May 2013 09:58:54 -0700 (PDT)
In-Reply-To: <008d01ce4c5d$cfd36410$6f7a2c30$@lge.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09-05-2013 6:35, Jongsung Kim wrote:

>>      Removal of unused #define's is a matter of a separate cleanup patch...

> Sorry. I won't touch them.

>>> +static int rtl8201f_ack_interrupt(struct phy_device *phydev) {
>>> +	int err;
>>> +
>>> +	err = phy_read(phydev, RTL8201F_ISR);

>>     This could be an initializer and so make the function shorter.

> Agreed. I just thought it's better to make it similar to the
> rtl821x_ack_interrupt.

    Ah, then you may leave this code as is.

> Then, may I make shorter the rtl821x_ack_interrupt as
> well as rtl8201f_ack_interrupt?

    In a separate patch, if you wish.

WBR, Sergei
