From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: linux-next: manual merge of the staging tree with the net
 tree
Date: Thu, 6 Oct 2011 10:59:10 +0200
Message-ID: <4E8D6DDE.9050102@broadcom.com>
References: <20111006155810.14a6b5c199edc388bbf11437@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Greg KH" <greg@kroah.com>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Eliad Peller" <eliad@wizery.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Stephen Rothwell" <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20111006155810.14a6b5c199edc388bbf11437@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/06/2011 06:58 AM, Stephen Rothwell wrote:
> Hi Greg,
>
> Today's linux-next merge of the staging tree got a conflict in
> drivers/staging/brcm80211/brcmsmac/mac80211_if.c between commit
> 37a41b4affa3 ("mac80211: add ieee80211_vif param to tsf functions") from
> the net tree and commit 3956b4a2ddb0 ("staging: brcm80211: remove locking
> macro definitions") from the staging tree.
>
> I fixed it up (which essentially means I used the staging tree version
> with one small change to the brcms_ops_conf_tx prototype) and can carry
> the fixes as necessary.

Thanks, Stephen

I had to make the mac80211 conf_tx callback change  for the mainline 
patch as well.

Acked.

Gr. AvS
