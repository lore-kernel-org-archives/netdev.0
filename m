From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable: Prevent spurious EBUSY errors on insertion
Date: Fri, 18 Dec 2015 10:26:54 +0800
Message-ID: <20151218022654.GA18495@gondor.apana.org.au>
References: <1448039840-11367-1-git-send-email-phil@nwl.cc>
 <20151130093755.GA8159@gondor.apana.org.au>
 <20151130101401.GA17712@orbit.nwl.cc>
 <20151130101859.GA8378@gondor.apana.org.au>
 <20151203124129.GA5505@gondor.apana.org.au>
 <CADvbK_cA5qaooTOE4Z2bGYs+ys17ZajSMgKDVWgctSZWJ0vjpw@mail.gmail.com>
 <20151217084809.GC9239@gondor.apana.org.au>
 <CADvbK_df=Z1re2wPUF9JCXggBzRqF=Tgt86PXV0KqBcx3VeVNA@mail.gmail.com>
 <CADvbK_e_H91UAatLSOEAvPFxZZTNNs5ZFR5TieXBdWt65z4Qzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Phil Sutter <phil@nwl.cc>, davem <davem@davemloft.net>,
	network dev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org, tgraf@suug.ch,
	fengguang.wu@intel.com, wfg@linux.intel.com, lkp@01.org
To: Xin Long <lucien.xin@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CADvbK_e_H91UAatLSOEAvPFxZZTNNs5ZFR5TieXBdWt65z4Qzg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 18, 2015 at 12:07:08AM +0800, Xin Long wrote:
>
> I'm just wondering, why do not we handle the genuine double rehash
> issue inside rhashtable? i mean it's just a temporary error that a
> simple retry may fix it.

Because a double rehash means that someone has cracked your hash
function and there is no point in trying anymore.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
