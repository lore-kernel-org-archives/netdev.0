From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Where exactly will arch_fast_hash be used
Date: Sun, 07 Dec 2014 15:06:43 +0100
Message-ID: <1417961203.17658.52.camel@localhost>
References: <20141207132305.24691.qmail@ns.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	dborkman@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, tgraf@suug.ch, tytso@mit.edu
To: George Spelvin <linux@horizon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141207132305.24691.qmail@ns.horizon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On So, 2014-12-07 at 08:23 -0500, George Spelvin wrote:
> So there are plenty of hash tables in Linux that you don't dare use this
> with.  In fact, so many that, as you rightly point out, it's not clear
> if it's worth providing this special optimization for the few remaining.

In case of openvswitch it shows a performance improvment. The seed
parameter could be used as an initial biasing of the crc32 function, but
in case of openvswitch it is only set to 0.

Bye,
Hannes
