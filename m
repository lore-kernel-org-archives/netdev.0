From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: RFC  [PATCH] iproute2:  temporary solution to fix xt breakage
Date: Mon, 17 Dec 2012 08:12:03 -0800
Message-ID: <20121217081203.3dc324c8@nehalam.linuxnetplumber.net>
References: <50C4821D.5090206@gmail.com>
	<50C9B4BB.9060609@mojatatu.com>
	<50CCE961.5050204@mojatatu.com>
	<alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr>
	<CAASe=fQT2pVOK0uctdaKL+aOrF8nYeTMfoF15kmd-rC02+7Vnw@mail.gmail.com>
	<50CDFB6A.3090806@mojatatu.com>
	<50CE1A04.1000405@mojatatu.com>
	<alpine.LNX.2.01.1212162003340.27614@nerf07.vanv.qr>
	<50CE3203.9080007@mojatatu.com>
	<50CF1071.1050405@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Hasan Chowdhury <shemonc@gmail.com>,
	Jan Engelhardt <jengelh@inai.de>,
	Yury Stankevich <urykhy@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <50CF1071.1050405@mojatatu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 17 Dec 2012 07:30:41 -0500
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> On 12-12-16 03:41 PM, Jamal Hadi Salim wrote:
> >
> > There is an "intermediate solution" from Hasan which doesnt require
> > the kernel change. It changes the kernel endpoint to "ipt". I am
> > conflicted because it is a quick hack while otoh forcing people to
> > upgrade kernel is a usability issue.
> >
> 
> 
> Attached. Author is Hasan - I didnt sign it because i am looking for
> feedback and i find it distasteful but it solves the problem.
> This is needed until we have a proper fix in the kernel propagated.
> Once that kernel change is ubiquitous this change is noise and a
> maintanance pain. I am making it hard to even turn it on
> (i.e someone knowledgeable will have to compile with CONFIG_XT_HACK)
> 
> cheers,
> jamal
> 
> 

Maybe xtables should have stable API/ABI and use shim routines there?
