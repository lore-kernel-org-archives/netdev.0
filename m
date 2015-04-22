From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/6] crypto: Make all AEAD users include aead.h
Date: Wed, 22 Apr 2015 09:18:48 +0200
Message-ID: <1429687128.2185.0.camel@sipsolutions.net>
References: <20150422070455.GA8351@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Marcel Holtmann <marcel@holtmann.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20150422070455.GA8351@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-04-22 at 15:04 +0800, Herbert Xu wrote:
> Hi:
> 
> This series adds inclusions of aead.h to all AEAD users including
> AEAD implementors (where it's internal/aead.h).  This is necessary
> because I'll be adding an updated AEAD interface and that will live
> in aead.h instead of crypto.h.
> 
> Dave, if it's OK with you I'd like to push the last two patches
> through my tree as the new AEAD interface would depend on them.

Looks good to me. Fine with me if you do that for the mac80211 patch,
I'm not expecting to change that file and cause conflicts.

johannes
