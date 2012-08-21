From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: coping with memory limitations and packet flooding in
 codel and fq_codel
Date: Tue, 21 Aug 2012 12:50:18 +0200
Message-ID: <1345546218.5158.449.camel@edumazet-glaptop>
References: <CAA93jw7=K8Vvp6N5qYZ8gaODaFyZtAEjGyQe2BDh9-RBsvVHcQ@mail.gmail.com>
	<1345538298.5158.401.camel@edumazet-glaptop>
	<46C4C66E-A4EE-4051-9686-7AD02EE925B4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, codel@lists.bufferbloat.net
To: Andrew McGregor <andrewmcgr@gmail.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <46C4C66E-A4EE-4051-9686-7AD02EE925B4@gmail.com>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

On Tue, 2012-08-21 at 22:27 +1200, Andrew McGregor wrote:
> On 21/08/2012, at 8:38 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > ath9k driver is known to deliver very fat skbs (skb->truesize is too
> > big)
> 
> What would it take to fix this?
> 
> Andrew

Someone could use the following : 

https://gerrit.chromium.org/gerrit/#/c/18412/
