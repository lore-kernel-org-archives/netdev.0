From: David Miller <davem@davemloft.net>
Subject: Re: ERR_PTR pattern in phylib
Date: Thu, 02 Sep 2010 09:34:51 -0700 (PDT)
Message-ID: <20100902.093451.189703514.davem@davemloft.net>
References: <AANLkTimjVZTNeLdm4qptU1MqREODLASdGGanUyxqxfub@mail.gmail.com>
	<alpine.LFD.2.00.1009021617500.410@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@freescale.com,
	linuxppc-dev@lists.ozlabs.org
To: macro@linux-mips.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <alpine.LFD.2.00.1009021617500.410@eddie.linux-mips.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

From: "Maciej W. Rozycki" <macro@linux-mips.org>
Date: Thu, 2 Sep 2010 16:20:34 +0100 (BST)

>  Arguably using a union here would make things cleaner and any reasonable 
> ABI will place small unions used as arguments or return values in 
> registers, but I'm not sure if the cost of the rewrite is worth the 

Well, sparc 32-bit's ABI for one is "not reasonable" and these return
values will always get stack slots and passed back by reference.
