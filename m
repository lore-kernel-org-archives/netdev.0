From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: aes_ccm: move struct aead_req off the stack
Date: Fri, 14 Oct 2016 15:11:18 +0200
Message-ID: <1476450678.31114.43.camel@sipsolutions.net>
References: <1476450540-1760-1-git-send-email-ard.biesheuvel@linaro.org>
         (sfid-20161014_150908_308224_F47D6BD7) <1476450635.31114.42.camel@sipsolutions.net>
         (sfid-20161014_151049_007103_7C55AE25)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, luto@amacapital.net,
        sergey.senozhatsky.work@gmail.com, netdev@vger.kernel.org,
        herbert@gondor.apana.org.au, davem@davemloft.net,
        linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
        j@w1.fi
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476450635.31114.42.camel@sipsolutions.net> (sfid-20161014_151049_007103_7C55AE25)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-10-14 at 15:10 +0200, Johannes Berg wrote:
> > 
> > So use kzalloc
> 
> Do we really need kzalloc()? We have things on the stack right now,
> and don't initialize, so surely we don't really need to zero things? 

Err, never mind, I'm an idiot - we *do* initialize to 0, of course.

johannes
