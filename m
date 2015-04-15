From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [Xen-devel] "tcp: refine TSO autosizing" causes performance regression
 on Xen
Date: Wed, 15 Apr 2015 11:19:15 -0700
Message-ID: <552EABA3.30109@hp.com>
References: <alpine.DEB.2.02.1504091344260.7690@kaball.uk.xensource.com> <1428596218.25985.263.camel@edumazet-glaptop2.roam.corp.google.com> <alpine.DEB.2.02.1504091729160.7690@kaball.uk.xensource.com> <CAFLBxZaVjFHh4UBnksGZS4waBr4jLdO8aJegyKvsU1-TvVt2Dg@mail.gmail.com> <1428932970.3834.4.camel@edumazet-glaptop2.roam.corp.google.com> <CAFLBxZYt7-v29ysm=f+5QMOw64_QhESjzj98udba+1cS-PfObA@mail.gmail.com> <1429115934.7346.107.camel@edumazet-glaptop2.roam.corp.google.com> <552E9E8D.1080000@eu.citrix.com> <1429118948.7346.114.camel@edumazet-glaptop2.roam.corp.google.com> <552EA2BC.5000707@eu.citrix.com> <1429120373.7346.125.camel@edumazet-glaptop2.roam.corp.google.com> <552EA604.8010400@hp.com> <1429121303.7346.126.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: George Dunlap <george.dunlap@eu.citrix.com>,
	Jonathan Davies <Jonathan.Davies@citrix.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Paul Durrant <paul.durrant@citrix.com>,
	Christoffer Dall <christoffer.dall@linaro.org>,
	Felipe Franciosi <felipe.franciosi@citrix.com>,
	linux-arm-kernel@lists.infradead.org,
	David Vrabel <david.vrabel@citrix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429121303.7346.126.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/15/2015 11:08 AM, Eric Dumazet wrote:
> On Wed, 2015-04-15 at 10:55 -0700, Rick Jones wrote:
>>>
>>> Have you tested this patch on a NIC without GSO/TSO ?
>>>
>>> This would allow more than 500 packets for a single flow.
>>>
>>> Hello bufferbloat.
>>
>> Woudln't the fq_codel qdisc on that interface address that problem?
>
> Last time I checked, default qdisc was pfifo_fast.

Bummer.

> These guys do not want to change a sysctl, how pfifo_fast will magically
> becomes fq_codel ?

Well, I'm not sure that it is George and Jonathan themselves who don't 
want to change a sysctl, but the customers who would have to tweak that 
in their VMs?

rick
