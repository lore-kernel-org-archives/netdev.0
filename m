From: David Miller <davem@davemloft.net>
Subject: Re: [2.6.30-rc3] powerpc: compilation error of mace module
Date: Sun, 26 Apr 2009 23:06:48 -0700 (PDT)
Message-ID: <20090426.230648.254087966.davem@davemloft.net>
References: <20090426155708.GA23159@ime.usp.br>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: rbrito@ime.usp.br
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20090426155708.GA23159@ime.usp.br>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

From: Rog=E9rio Brito <rbrito@ime.usp.br>
Date: Sun, 26 Apr 2009 12:57:09 -0300

> I am attempting to compile a new kernel for my OldWorld ppc box and I'm
> having some problems. The first one that appears to happen is the followi=
ng:

Turn on CONFIG_COMPAT_NET_DEV_OPS in your kernel config.

There was no reason for you to turn that off, and you had
to have done it explicitly I think :-)

Or, if you're bored, feel free to convert the mace driver over
to netdev_ops :-)
