From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: aead api to reduce redundancy
Date: Sun, 24 Sep 2017 17:05:31 +0200
Message-ID: <1506265531.2909.5.camel@sipsolutions.net>
References: <20170924054015.8958-1-qasdfgtyuiop@gmail.com>
         (sfid-20170924_074130_810821_889115CC)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Xiang Gao <qasdfgtyuiop@gmail.com>, herbert@gondor.apana.org.au,
        davem@davemloft.net, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20170924054015.8958-1-qasdfgtyuiop@gmail.com> (sfid-20170924_074130_810821_889115CC)
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2017-09-24 at 01:40 -0400, Xiang Gao wrote:
> Currently, the aes_ccm.c and aes_gcm.c are almost line by line
> copy of each other. This patch reduce code redundancy by moving
> the code in these two files to crypto/aead_api.c to make it a
> higher level aead api. The aes_ccm.c and aes_gcm.c are removed
> and all the functions are now implemented in their headers using
> the newly added aead api.
> 
No objection from me, though I'd ask you to respin with the indentation
fixed up a bit.

johannes
