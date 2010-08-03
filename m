From: Michele Petrazzo - Unipex <michele.petrazzo@unipex.it>
Subject: Re: [ANNOUNCE]: Release of iptables-1.4.9
Date: Tue, 03 Aug 2010 19:29:50 +0200
Message-ID: <4C58520E.5000906@unipex.it>
References: <4C5832F9.50004@trash.net> <x6bp9jy7sj@gzp>	<4C584C63.8010607@trash.net> <x6vd7rwrah@gzp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"'netfilter@vger.kernel.org'" <netfilter@vger.kernel.org>,
	netfilter-announce@lists.netfilter.org
To: "Gabor Z. Papp" <gzp@papp.hu>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <x6vd7rwrah@gzp>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gabor Z. Papp wrote:
> * Patrick McHardy <kaber@trash.net>:
> 
> | Did you use a git checkout/patch against 1.4.8 or the tar.bz2?
> | In case its the former, try running make clean, sh autogen.sh and
> | sh configure again before the build.
> 
> Used the tarball, but tried git also:
> 

Here git works. Or better, compile but I don't find the "iptables" command.

If I enable static compilation "configure --enable-static", I receive:
extensions/libext4.a(initext4.o): In function `init_extensions':
/home/devel/iptables/extensions/initext4.c:103: undefined reference to
`libxt_IDLETIMER_init'
/home/devel/iptables/extensions/initext4.c:137: undefined reference to
`libxt_TEE_ini


Michele
