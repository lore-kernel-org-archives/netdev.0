From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Tue, 19 Jun 2007 18:00:43 +0400
Message-ID: <20070619140038.GA13629@2ka.mipt.ru>
References: <OFB311484E.057E34E9-ON652572F3.001D5838-652572F3.0022766D@in.ibm.com> <1181216629.4064.22.camel@localhost> <20070619132148.GA32078@2ka.mipt.ru> <20070619133333.GA19667@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Gagan Arneja <gaagaan@gmail.com>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:38597 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752777AbXFSOGL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2007 10:06:11 -0400
Content-Disposition: inline
In-Reply-To: <20070619133333.GA19667@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 19, 2007 at 05:33:33PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> On Tue, Jun 19, 2007 at 05:21:48PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > Simple test included test -> desktop and vice versa traffic with 128 and
> > 4096 block size in netperf-2.4.3 setup.
> 
> I.e. it is not pktgen, but usual userspace application, which should not
> use new batch methods.
> 
> I will try to find pktget scripts posted in this thread.

pktgen reults are quite poor:
batch (changed from default script: count reduced, clone increased to 10k)
241319pps 115Mb/sec

mainline (the same script, on start it wrote about unsupported batch_low
parameter:
497520pps 238Mb/sec

-- 
	Evgeniy Polyakov
