From: Andi Kleen <andi@firstfloor.org>
Subject: Re: PATCH] filter: fix sk_filter rcu handling
Date: Sun, 5 Dec 2010 22:08:40 +0100
Message-ID: <20101205210840.GB7668@basil.fritz.box>
References: <AANLkTin6d=t6U28A-r=FznqE+5QuGXwg1tStOw-JXabg@mail.gmail.com>
	<1291192967.2856.492.camel@edumazet-laptop>
	<18eaf7d286236427b1632b9af62be513@localhost>
	<20101201.101809.71122121.davem@davemloft.net>
	<1291357953.2854.46.camel@edumazet-laptop>
	<1291582432.2806.300.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hagen@jauu.net, stable@kernel.org,
        xiaosuo@gmail.com, wirelesser@gmail.com,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        David Miller <davem@davemloft.net>, Pavel Emelyanov <xemul@openvz.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <stable-bounces@linux.kernel.org>
Content-Disposition: inline
In-Reply-To: <1291582432.2806.300.camel@edumazet-laptop>
List-Unsubscribe: <http://linux.kernel.org/mailman/options/stable>,
	<mailto:stable-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/mailman/private/stable/>
List-Post: <mailto:stable@linux.kernel.org>
List-Help: <mailto:stable-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/stable>,
	<mailto:stable-request@linux.kernel.org?subject=subscribe>
Sender: stable-bounces@linux.kernel.org
Errors-To: stable-bounces@linux.kernel.org
List-Id: netdev.vger.kernel.org

> While working on this, I found an annoying problem with current code.
> 
> This patch is a stable candidate.

Does this actually fix a real world problem someone is experiencing? 
"Theoretical races" are normally outside stable's scope.

-Andi
