From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/2] net: ethernet: sxgbe: remove private tx queue lock
Date: Fri, 9 Dec 2016 00:19:43 +0100
Message-ID: <20161208231943.GA13102@electric-eye.fr.zoreil.com>
References: <1481141138-19466-1-git-send-email-LinoSanfilippo@gmx.de>
 <1481141138-19466-2-git-send-email-LinoSanfilippo@gmx.de>
 <20161207231534.GB5889@electric-eye.fr.zoreil.com>
 <051e3043-8b58-0591-36e3-99e2267f67f4@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com, pavel@ucw.cz,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <051e3043-8b58-0591-36e3-99e2267f67f4@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lino Sanfilippo <LinoSanfilippo@gmx.de> :
[...]
> OTOH Pavel said that he actually could produce a deadlock. Now I wonder if
> this is caused by that locking scheme (in a way I have not figured out yet)
> or if it is a different issue.

stmmac_tx_err races with stmmac_xmit.

-- 
Ueimor
