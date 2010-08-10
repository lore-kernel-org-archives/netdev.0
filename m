From: Christian Dietrich <qy03fugy@stud.informatik.uni-erlangen.de>
Subject: Dead Config Option STMMAC_ETH?
Date: Tue, 10 Aug 2010 14:28:47 +0200
Message-ID: <86r5i6vegw.fsf@peer.zerties.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "vamos-dev\@i4.informatik.uni-erlangen.de"
	<vamos-dev@i4.informatik.uni-erlangen.de>
To: "David S. Miller" <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all!
      =20
        As part of the VAMOS[0] research project at the University of
Erlangen we are looking at multiple integrity errors in linux'
configuration system.

        I've been running a check on the drivers/net/stmmac sourcetree =
for
config Items not defined in Kconfig and found such a case. Sourcecode
blocks depending on these Items are not reachable from a vanilla
kernel -- dead code. I've seen such dead blocks made on purpose
e.g. while integrating new features into the kernel but generally
they're just useless.

As far as i can see in drivers/net/stmmac/Kconfig STMMAC_ETH and severa=
l
depending flags are dead in the linux vanilla kernel, because it depend=
s
on CPU_SUBTYPE_ST40, but there isn't a Kconfig option for that. But
f96691872439ab2071171d4531c4a95b5d493ae5 suggests, that support for thi=
s
ST40 plattform was removed in 2007.

There seems to be, that there was much effort on the stmmac drivers in
the last few months, so i just wanted to ask if this problem is known.

Regards

        Christian Dietrich

[0] http://vamos1.informatik.uni-erlangen.de
--=20
(=CE=BB x . x x) (=CE=BB x . x x) -- See how beatiful the lambda is
No documentation is better than bad documentation
-- Das Ausdrucken dieser Mail wird urheberrechtlich verfolgt.
