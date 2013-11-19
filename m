From: Willy Tarreau <w@1wt.eu>
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Tue, 19 Nov 2013 19:41:21 +0100
Message-ID: <20131119184121.GN913@1wt.eu>
References: <87a9hagex1.fsf@natisbad.org> <20131112100126.GB23981@1wt.eu>
 <87vbzxd473.fsf@natisbad.org> <20131113072257.GB10591@1wt.eu>
 <20131117141940.GA18569@1wt.eu>
 <1384710098.8604.58.camel@edumazet-glaptop2.roam.corp.google.com>
 <87li0kkhzx.fsf@natisbad.org>
 <1384869194.8604.92.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131119174323.GH913@1wt.eu>
 <1384885910.8604.110.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Florian Fainelli <f.fainelli@gmail.com>, simon.guinot@sequanux.org,
 netdev@vger.kernel.org, Arnaud Ebalard <arno@natisbad.org>,
 edumazet@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
 linux-arm-kernel@lists.infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1384885910.8604.110.camel@edumazet-glaptop2.roam.corp.google.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 19, 2013 at 10:31:50AM -0800, Eric Dumazet wrote:
> On Tue, 2013-11-19 at 18:43 +0100, Willy Tarreau wrote:
> 
> > - #define MVNETA_TX_DONE_TIMER_PERIOD 10
> > + #define MVNETA_TX_DONE_TIMER_PERIOD (1000/HZ)
> > 
> 
> I suggested this in a prior mail :
> 
> #define MVNETA_TX_DONE_TIMER_PERIOD 1

Ah sorry, I remember now.

> But apparently it was triggering strange crashes...

Ah, when a bug hides another one, it's the situation I prefer, because
by working on one, you end up fixing two :-)

Cheers,
Willy
