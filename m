From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Thu, 7 Aug 2008 14:11:56 +0200
Message-ID: <200808071411.57977.thomas.jarosch@intra2net.com>
References: <47EA0DAB.7080205@securenet.de> <Pine.LNX.4.64.0808070950260.3859@wrl-59.cs.helsinki.fi> <200808071450.43552.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Ilpo =?iso-8859-1?q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	"=?iso-8859-1?q?D=E2niel?= Fraga" <fragabr@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	David Miller <davem@davemloft.net>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <200808071450.43552.denys@visp.net.lb>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, 7. August 2008 13:50:42 Denys Fedoryshchenko wrote:
> By the way, i had also problem with frto with local connections, and it was
> trivial to reproduce. But because of proprioetary(but i have sources)
> userspace application and specific way of using it - i didn't report to
> maillist. But after patch is ready, add me please in cc, i will test it
> with me too.
>
> For me disabling frto helps to solve problem. With frto i have
> connections "stalling", if there is trasferred large chunks of data over
> loopback. It is complicated way how it works all - but i can try to explain
> how everything works, if required.

What kernel version are you using?

IMHO this could only happen on the loopback interface
if you are a) using an "old" kernel version like 2.6.24/2.6.25
or b) there might be a bug hidden somewhere else.

Ilpo has sent the "final" patch to linux-netdev
some minutes ago, give it a try.

Thomas
