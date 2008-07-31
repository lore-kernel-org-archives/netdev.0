From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Thu, 31 Jul 2008 15:47:55 +0200
Message-ID: <200807311547.57189.thomas.jarosch@intra2net.com>
References: <47EA0DAB.7080205@securenet.de> <200807310939.42406.thomas.jarosch@intra2net.com> <20080731094436.12ec99ae@tux>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Ilpo =?iso-8859-1?q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	David Miller <davem@davemloft.net>
To: =?iso-8859-1?q?D=E2niel_Fraga?= <fragabr@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080731094436.12ec99ae@tux>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, 31. July 2008 14:44:36 D=E2niel Fraga wrote:
> > Ok. Please try the latest patch Ilpo CC:ed you. Here's a link to th=
e
> > post: http://marc.info/?l=3Dlinux-netdev&m=3D121699478406378&w=3D2
>
> 	Before I try could this issue be related to some of these
> kernel parameters?

If your problem is really FRTO related (that what the patch is for),
you could try to disable FRTO temporarily:

echo 0 > /proc/sys/net/ipv4/tcp_frto

> > Where is the NNTP server located? At your provider?
>
> 	It's my nntp server:
>
> nntp://news.abusar.org
>
> 	You can post test messages on grupo "u-br.teste".

Nice, so Ilpo can "test" (=3Dbombard) it with big messages ;-)

Thomas
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
