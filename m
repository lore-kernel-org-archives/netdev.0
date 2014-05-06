From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 06/24] net, diet: Use small UDP hash tables on small
 kernels
Date: Tue, 06 May 2014 12:25:54 -0700
Message-ID: <1399404354.15399.64.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
	 <1399328773-6531-7-git-send-email-andi@firstfloor.org>
	 <1399386402.15399.11.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140506182344.GL19657@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com
To: Andi Kleen <ak@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140506182344.GL19657@tassilo.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-05-06 at 11:23 -0700, Andi Kleen wrote:

> Ok I need to fix that, because a single slot on a 2MB system 
> is likely not enough.

You have nothing to do.

It will use a 128 slots hash table with current code.
