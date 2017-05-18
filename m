From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: dsa: headers cleanup
Date: Thu, 18 May 2017 10:36:37 -0400 (EDT)
Message-ID: <20170518.103637.731007825504911583.davem@davemloft.net>
References: <20170517194605.31639-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170517194605.31639-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Wed, 17 May 2017 15:46:02 -0400

> The DSA core files share a common private header file. Include the DSA
> public header there instead of independently in each core source file.
> 
> DSA core and its drivers use switchdev, thus include switchdev.h in the
> public DSA header. This allows us to get rid of the forward declaration
> and use typedef defined by switchdev.

This looks fine, series applied, thanks.
