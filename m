From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 06/24] net, diet: Use small UDP hash tables on small
 kernels
Date: Tue, 6 May 2014 11:23:44 -0700
Message-ID: <20140506182344.GL19657@tassilo.jf.intel.com>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
 <1399328773-6531-7-git-send-email-andi@firstfloor.org>
 <1399386402.15399.11.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1399386402.15399.11.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> This patch has no effect on a small machine, because we already
> dynamically size this hash table.

Good point.

> 
> (The factor is one slot per 2MB of low memory)

Ok I need to fix that, because a single slot on a 2MB system 
is likely not enough.

-Andi
