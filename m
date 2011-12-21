From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: linux-next: manual merge of the wireless-next tree with the
 tree
Date: Wed, 21 Dec 2011 11:47:09 +0100
Message-ID: <4EF1B92D.9040405@broadcom.com>
References: <20111221124931.992e4e4265f2c3cd1d2e75b4@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Rusty Russell" <rusty@rustcorp.com.au>,
	"David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: "Stephen Rothwell" <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20111221124931.992e4e4265f2c3cd1d2e75b4@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/21/2011 02:49 AM, Stephen Rothwell wrote:
> Hi John,
> 
> Today's linux-next merge of the wireless-next tree got a conflict in
> drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c between commit
> 3db1cd5c05f3 ("net: fix assignment of 0/1 to bool variables") from the
> tree and commit 3fb1d8d2dad3 ("brcm80211: fmac: move driver up status to
> struct brcmf_bus") from the wireless-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary.
> 

Thanks, Stephen

I noticed Rusty's patch and the use of 0/1 for bool in our tree. Was
going to fix that, but this fix looks fine.

Gr. AvS
