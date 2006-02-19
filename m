From: hoerdt@clarinet.u-strasbg.fr
Subject: (usagi-users 03609) IPv6 setsockopt software MTU patch
Date: Sun, 19 Feb 2006 14:47:09 +0100
Message-ID: <20060219134709.GC16304@clarinet.u-strasbg.fr>
References: <43F5A7B2.90803@6wind.com> <20060217.215101.09874309.yoshfuji@linux-ipv6.org>
Reply-To: usagi-users@linux-ipv6.org
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: davem@davemloft.net, netdev@vger.kernel.org, olivier.matz@6wind.com,
        yoshfuji@linux-ipv6.org
Return-path: <usagi-users-admin@linux-ipv6.org>
To: usagi-users@linux-ipv6.org
In-Reply-To: <20060217.215101.09874309.yoshfuji@linux-ipv6.org>
Content-Disposition: inline
List-Software: fml [fml 4.0.3 release (20011202/4.0.3)]
List-Post: <mailto:usagi-users@linux-ipv6.org>
List-Owner: <mailto:usagi-users-admin@linux-ipv6.org>
List-Help: <mailto:usagi-users-ctl@linux-ipv6.org?body=help>
List-Unsubscribe: <mailto:usagi-users-ctl@linux-ipv6.org?body=unsubscribe>
List-Id: netdev.vger.kernel.org

Hi,

In my precedent mails, i pointed out that IPV6_MTU setsockopt
was ineffective because the field frag_size was not used further
in the ipv6 fragment code of the kernel. You can check out
that this is the case by this simple proof of concept code :

http://clarinet.u-strasbg.fr/~hoerdt/mtu.c

The fix is very simple, it only grab the value of frag_size and
use it in ip6_fragment file, could you please review the patch which
fix that problem at :

http://clarinet.u-strasbg.fr/~hoerdt/ip6_output.c.softfrag.patch

Thanks for the attention,

Hoerdt Micka=EBl
