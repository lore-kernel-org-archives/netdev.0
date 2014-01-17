From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 3/3] reciprocal_divide: correction/update of
 the algorithm
Date: Thu, 16 Jan 2014 21:42:58 -0800
Message-ID: <1389937378.31367.470.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389918519-23779-1-git-send-email-hannes@stressinduktion.org>
	 <1389918519-23779-4-git-send-email-hannes@stressinduktion.org>
	 <1389926017.31367.464.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140117042901.GB26022@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Austin S Hemmelgarn <ahferroin7@gmail.com>,
	linux-kernel@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Matt Mackall <mpm@selenic.com>,
	Pekka Enberg <penberg@kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Jakub Zawadzki <darkjames-ws@darkjames.pl>,
	Daniel Borkmann <dborkman@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140117042901.GB26022@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-01-17 at 05:29 +0100, Hannes Frederic Sowa wrote:

> Also I doubt the performance drop for SLAB will be that massive. Also it was
> already replaced by SLUB as the default SLAB allocator, which doesn't use
> reciprocal_divide.

Google servers use SLAB, not SLUB, for various reasons, and performance
is one of them.
