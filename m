From: Mike Galbraith <efault@gmx.de>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Sun, 12 Oct 2008 08:33:40 +0200
Message-ID: <1223793220.7736.2.camel@marge.simson.net>
References: <20081009231759.GA8664@tservice.net.ru>
	 <1223633623.4138.86.camel@marge.simson.net>
	 <20081011131352.GA16908@tservice.net.ru>  <1223735947.8485.33.camel@twins>
	 <1223748830.4598.16.camel@marge.simson.net>
	 <1223791374.7521.59.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <s0mbre@tservice.net.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	David Miller <davem@davemloft.net>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754190AbYJLGdx@vger.kernel.org>
In-Reply-To: <1223791374.7521.59.camel@marge.simson.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2008-10-12 at 08:02 +0200, Mike Galbraith wrote:

> Data:
> 
> read/write requests/sec per client count
>                             1       2       4       8      16      32      64     128     256  
> 2.6.26.6.mysql		 7978	19856	37238	36652	34399	33054	31608	27983	23411
> 2.6.27.mysql		 9618	18329	37128	36504	33590	31846	30719	27685	21299
> 2.6.27.rev.mysql	10944	19544	37349	36582	33793	31744	29161	25719	21026
> 2.6.28.git.mysql	 9518	18031	30418	33571	33330	32797	31353	29139	25793
> 									
> 2.6.26.6.pgsql		14165	27516	53883	53679	51960	49694	44377	35361	32879
> 2.6.27.pgsql		14146	27519	53797	53739	52850	47633	39976	30552	28741
> 2.6.27.rev.pgsql	14168	27561	53973	54043	53150	47900	39906	31987	28034
> 2.6.28.git.pgsql	14404	28318	55124	55010	55002	54890	53745	53519	52215

P.S.  all knobs stock, TSO/GSO off.
