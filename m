From: Willy Tarreau <w@1wt.eu>
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Tue, 12 Nov 2013 09:36:33 +0100
Message-ID: <20131112083633.GB10318@1wt.eu>
References: <8761s0cqhh.fsf@natisbad.org>
 <slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site> <87y54u59zq.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, edumazet@google.com,
 stable@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 netdev@vger.kernel.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <87y54u59zq.fsf@natisbad.org>
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

On Tue, Nov 12, 2013 at 08:56:25AM +0100, Arnaud Ebalard wrote:
> I had some offline (*) discussions w/ Eric and did some test w/ the patches
> he sent. It does not fix the regression I see. It would be nice if someone
> w/ the hardware and more knowledge of mvneta driver could reproduce the
> issue and spend some time on it.

I could give it a try but am falling very short of time at the moment.

> That been said, even if the driver is most probably not the only one to
> blame here (considering the result of bisect and current thread on
> netdev), I never managed to get the performance I have on my ReadyNAS
> Duo v2 (i.e. 108MB/s for a file served by an Apache) with a mvneta-based
> platform (RN102, RN104 or RN2120). Understanding why is on an already a
> long todo list. 

Yes I found that your original numbers were already quite low, so it is
also possible that you have a different problem (eg: faulty switch or
auto-negociation problem where the switch goes to half duplex because
the neta does not advertise nway or whatever) that is emphasized by the
latest changes.

> Cheers,
> 
> a+
> 
> (*): for some reasons, my messages to netdev and stable are not published
> even though I can interact w/ {majordomo,autoanswer}@vger.kernel.org. I
> poked postmaster@ bug got no reply yet.

I can confirm that I got this message from you on netdev so it should be OK
now.

Willy
