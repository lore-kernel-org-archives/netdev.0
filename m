From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH 1/1] netfilter: Add possibility to turn off netfilters defrag per netns
Date: Wed, 4 Jan 2012 09:49:53 +0100
Message-ID: <201201040949.54985.hans.schillstrom@ericsson.com>
References: <1325664443-10320-1-git-send-email-hans.schillstrom@ericsson.com> <alpine.DEB.2.00.1201040922020.925@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1201040922020.925@blackhole.kfki.hu>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Jozsef

On Wednesday 04 January 2012 09:28:05 Jozsef Kadlecsik wrote:
> Hi Hans,
> 
> On Wed, 4 Jan 2012, Hans Schillstrom wrote:
> 
> > In some cases it not desirable to have auto defrag.
> > Ex. in a cluster where packets can arrive on different blades.
> > In that case it is possible to use containers (LXC) and send
> > all fragments to one place where defrag is enabled.
> > 
> > This patch makes it possible to turn off the defrag per network name space,
> > by setting net.netfilter.nf_conntrack_nodefrag to 1.
> > Both IPv4 and IPv6 is effected by this sysctl.
> > Default is 0 which is defrag.
> 
> Conntrack assumes that the packets are defragmented and will drop any 
> unfragmented one. So your patch results packet drops.

Hmmm, more work...
> 
> Also, if you want to disable defragmentation then why don't you simply 
> "mark" the packets with the NOTRACK target?

I don't think that will work since NF_IP_PRI_CONNTRACK_DEFRAG is -400

> 
> Best regards,
> Jozsef
>  

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
