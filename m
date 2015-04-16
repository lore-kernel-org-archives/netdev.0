From: Tim Deegan <tim@xen.org>
Subject: Re: [Xen-devel] "tcp: refine TSO autosizing" causes performance
 regression on Xen
Date: Thu, 16 Apr 2015 14:00:43 +0100
Message-ID: <20150416130043.GL13443@deinos.phlegethon.org>
References: <alpine.DEB.2.02.1504091729160.7690@kaball.uk.xensource.com>
 <CAFLBxZaVjFHh4UBnksGZS4waBr4jLdO8aJegyKvsU1-TvVt2Dg@mail.gmail.com>
 <1428932970.3834.4.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAFLBxZYt7-v29ysm=f+5QMOw64_QhESjzj98udba+1cS-PfObA@mail.gmail.com>
 <1429115934.7346.107.camel@edumazet-glaptop2.roam.corp.google.com>
 <552E9E8D.1080000@eu.citrix.com>
 <1429119688.7346.123.camel@edumazet-glaptop2.roam.corp.google.com>
 <alpine.DEB.2.02.1504151846110.7690@kaball.uk.xensource.com>
 <1429121867.7346.136.camel@edumazet-glaptop2.roam.corp.google.com>
 <552F9F60.7090406@eu.citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jonathan Davies <Jonathan.Davies@citrix.com>,
 "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
 Wei Liu <wei.liu2@citrix.com>, Ian Campbell <Ian.Campbell@citrix.com>,
 Eric Dumazet <eric.dumazet@gmail.com>,
 Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
 netdev <netdev@vger.kernel.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 Eric Dumazet <edumazet@google.com>, Paul Durrant <paul.durrant@citrix.com>,
 Christoffer Dall <christoffer.dall@linaro.org>,
 Felipe Franciosi <felipe.franciosi@citrix.com>,
 linux-arm-kernel@lists.infradead.org, David Vrabel <david.vrabel@citrix.com>
To: George Dunlap <george.dunlap@eu.citrix.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <552F9F60.7090406@eu.citrix.com>
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

At 12:39 +0100 on 16 Apr (1429187952), George Dunlap wrote:
> Your comment lists three benefits:
> 1. better RTT estimation
> 2. faster recovery
> 3. high rates
> 
> #3 is just marketing fluff; it's also contradicted by the statement that
> immediately follows it -- i.e., there are drivers for which the
> limitation does *not* give high rates.

AFAICT #3 is talking about throughput _under TCP_, where inflating the
RTT will absolutely cause problems.

Tim.
