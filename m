From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Tue, 15 Jul 2008 13:47:22 +0200
Message-ID: <200807151347.23598.thomas.jarosch@intra2net.com>
References: <47EA0DAB.7080205@securenet.de> <Pine.LNX.4.64.0807102314440.14321@blackhole.kfki.hu> <200807111633.42514.thomas.jarosch@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <200807111633.42514.thomas.jarosch@intra2net.com>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, 11. July 2008 16:33:41 Thomas Jarosch wrote:
> On Thursday, 10. July 2008 23:21:37 Jozsef Kadlecsik wrote:
> > You did not mention the type of your driver. Isn't there some chang=
es in
> > the driver code between 2.6.23.17 and 2.6.24 which could cause such
> > stallings?
>
> It's a 8139too and the "same" hardware works fine at other sites.
> I tried the nmap trick mentioned by D=E2niel Fraga with no noticable
> difference.

I swapped the NIC with a "via-rhine" based card which is installed
in the remote box, but without much success.

Luckily I'm able to reproduce the problem locally using an ADSL line fr=
om the=20
same provider, so I'll now bisect the kernel from 2.6.23.17 to 2.6.24.

Thomas
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
