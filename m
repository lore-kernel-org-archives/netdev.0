From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: TCP_MD5 and Intel e1000
Date: Tue, 22 May 2007 10:57:38 +0200
Message-ID: <20070522105738.f03cb83b.dada1@cosmosbay.com>
References: <C2786969.24B46%webmaster@poweraudio.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Marc Donner <webmaster@poweraudio.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:42680 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755219AbXEVI5k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2007 04:57:40 -0400
In-Reply-To: <C2786969.24B46%webmaster@poweraudio.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 22 May 2007 09:33:29 +0200
Marc Donner <webmaster@poweraudio.de> wrote:

> Hi,
> 
> I have tried to set up quagga with tcp-md5 support from kernel. All seems ok
> with a intel e100 NIC, but as i testetd with a intel e1000 NIC the tcp
> packets have an invalid md5 digest.
> If i run tcpdump on the mashine the packets are generated, it shows on the
> outgoing interface invalid md5 digests.
> Are there known issues about tcp-md5 and e1000 NICs?
> 

Hi Marc

CCed netdev as more appropriate to discuss about network stuff.

Would be nice if you sent some tcpdump samples to share with us, and tell us
which exact linux version you tried.

You could try "ethtool -K tx off", and/or other ethtool -K settings

