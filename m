From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] stmmac: Add vlan rx for better GRO
 performance.
Date: Tue, 14 Jan 2014 10:12:05 -0800
Message-ID: <20140114101205.1d67fbe8@nehalam.linuxnetplumber.net>
References: <1389720846-6543-1-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com,
	rayagond@vayavyalabs.com
To: Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:55326 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562AbaANSMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 13:12:08 -0500
Received: by mail-pd0-f182.google.com with SMTP id v10so178121pde.13
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 10:12:07 -0800 (PST)
In-Reply-To: <1389720846-6543-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Jan 2014 11:34:06 -0600
Vince Bridgers <vbridgers2013@gmail.com> wrote:

> +static inline void stmmac_rx_vlan(struct net_device *dev, struct sk_buff *skb)
> +{

No need for explicit inline, let the compiler decide to inline.
