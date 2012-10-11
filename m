From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [Xen-devel] compound skb frag pages appearing in start_xmit
Date: Thu, 11 Oct 2012 12:20:04 +0200
Message-ID: <878987058.20121011122004@eikelenboom.it>
References: <1349790467.21847.185.camel@zakaz.uk.xensource.com> <1349790863.21172.4406.camel@edumazet-glaptop> <1349792241.21847.199.camel@zakaz.uk.xensource.com> <1349792847.21172.4479.camel@edumazet-glaptop> <1349793630.21847.208.camel@zakaz.uk.xensource.com> <1349863984.10070.26.camel@zakaz.uk.xensource.com> <1349874598.10070.39.camel@zakaz.uk.xensource.com> <748966751.20121010164949@eikelenboom.it> <1349942546.14806.7.camel@zakaz.uk.xensource.com> <151954917.20121011120004@eikelenboom.it> <1349949924.21172.8462.camel@edumazet-glaptop> <1349950494.14806.29.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	xen-devel <xen-devel@lists.xen.org>,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.121.164.40.188.clients.your-server.de ([188.40.164.121]:46541
	"EHLO smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757182Ab2JKKUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 06:20:12 -0400
In-Reply-To: <1349950494.14806.29.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thursday, October 11, 2012, 12:14:54 PM, you wrote:

> On Thu, 2012-10-11 at 11:05 +0100, Eric Dumazet wrote:
>> On Thu, 2012-10-11 at 12:00 +0200, Sander Eikelenboom wrote:
>> 
>> > Probably due to the BUG_ON from the patch below, i changed it into a WARN_ON.
>> > And i seem to hit it, but only in one of the guests at the moment and it triggers quite irregularly.
>> 
>> xennet_make_frags() is able to split the skb->head in multiple page-size
>> chunks.
>> 
>> It should do the same for fragments

> Right, I just want to be reproduce the issue so I can know I've fixed it
> properly ;-)

Trying to scp/sftp files from a guest seems to trigger it for me ..

> Ian.
