From: Willy Tarreau <w@1wt.eu>
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Tue, 12 Nov 2013 11:01:26 +0100
Message-ID: <20131112100126.GB23981@1wt.eu>
References: <8761s0cqhh.fsf@natisbad.org>
 <slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site> <87y54u59zq.fsf@natisbad.org>
 <20131112083633.GB10318@1wt.eu> <87a9hagex1.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, edumazet@google.com,
 linux-arm-kernel@lists.infradead.org, stable@vger.kernel.org,
 netdev@vger.kernel.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <87a9hagex1.fsf@natisbad.org>
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

Hi Arnaud,

On Tue, Nov 12, 2013 at 10:14:34AM +0100, Arnaud Ebalard wrote:
> Tests for the rgression were done w/ scp, and were hence limited by the
> crypto (16MB/s using arcfour128). But I also did some tests w/ a simple
> wget for a file served by Apache *before* the regression and I never got
> more than 60MB/s from what I recall. Can you beat that? 

Yes, I finally picked my mirabox out of my bag for a quick test. It boots
off 3.10.0-rc7 and I totally saturate one port (stable 988 Mbps) with even
a single TCP stream.

With two systems, one directly connected (dockstar) and the other one via
a switch, I get 2*650 Mbps (a single TCP stream is enough on each).

I'll have to re-run some tests using a more up to date kernel, but that
will probably not be today though.

Regards,
Willy
