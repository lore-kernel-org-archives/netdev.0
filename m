From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH, RFC] RCU : OOM avoidance and lower latency
Date: Sat, 7 Jan 2006 02:09:01 +0100
Message-ID: <200601070209.02157.ak@suse.de>
References: <43BEA693.5010509@cosmosbay.com> <200601062157.42470.ak@suse.de> <20060106.161721.124249301.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: paulmck@us.ibm.com, dada1@cosmosbay.com, alan@lxorguk.ukuu.org.uk,
	torvalds@osdl.org, linux-kernel@vger.kernel.org,
	dipankar@in.ibm.com, manfred@colorfullife.com,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752507AbWAGCSG@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060106.161721.124249301.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 07 January 2006 01:17, David S. Miller wrote:

> 
> I mean something like this patch:

Looks like a good idea to me.

I always disliked the per chain spinlocks even for other hash tables like
TCP/UDP multiplex - it would be much nicer to use a much smaller separately 
hashed lock table and save cache. In this case the special case of using
a one entry only lock hash table makes sense.

-Andi
