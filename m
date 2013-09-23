From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 01/12] tcp.h: Remove extern from function prototypes
Date: Mon, 23 Sep 2013 13:44:02 -0700
Message-ID: <1379969042.3575.65.camel@joe-AO722>
References: <445209f8885ccd8234fa787c30d63e63fc7917d7.1379961014.git.joe@perches.com>
	 <20130923.163010.976299939444640897.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130923.163010.976299939444640897.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-09-23 at 16:30 -0400, David Miller wrote:
> Series applied,

How about the same changes for the .h files in drivers/net ?

(slowly of course, and by maintained subsystem)

$ git grep -E "^\s*\bextern(\s+\w+){1,4}\s*\(\s*[^\*]" drivers/net/ | wc -l
1445

Maybe something like groups of:
$ git grep -E --name-only "^\s*\bextern(\s+\w+){1,4}\s*\(\s*[^\*]" drivers/net/  | \
	cut -f3- -d"/" | cut -f1,2 -d"/" | uniq | \
	while read file ; do if [ -d drivers/net/$file ] ; then echo $file ; fi ; done
can/mscan
can/softing
ethernet/8390
ethernet/adi
ethernet/amd
ethernet/atheros
ethernet/broadcom
ethernet/brocade
ethernet/chelsio
ethernet/cirrus
ethernet/emulex
ethernet/freescale
ethernet/ibm
ethernet/intel
ethernet/mellanox
ethernet/natsemi
ethernet/octeon
ethernet/oki-semi
ethernet/qlogic
ethernet/sfc
ethernet/stmicro
ethernet/ti
ethernet/toshiba
fddi/skfp
wimax/i2400m
wireless/ath
wireless/brcm80211
wireless/ipw2x00
wireless/iwlegacy
wireless/iwlwifi
wireless/mwifiex
wireless/orinoco
wireless/rtlwifi
