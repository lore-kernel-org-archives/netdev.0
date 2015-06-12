From: Valentin Rothberg <valentinrothberg@gmail.com>
Subject: Cavium Liquidio: select on undefined option LIBCRC32
Date: Fri, 12 Jun 2015 13:26:36 +0200
Message-ID: <CAD3Xx4J-nVXvOdV4wdos44Tvm8iR-c_bSwN=E5W+=RbOtTwTCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org, Paul Bolle <pebolle@tiscali.nl>,
	Andreas Ruprecht <andreas.ruprecht@fau.de>,
	hengelein Stefan <stefan.hengelein@fau.de>,
	netdev@vger.kernel.org, davem@davemloft.net,
	derek.chickles@caviumnetworks.com,
	satananda.burla@caviumnetworks.com,
	felix.manlunas@caviumnetworks.com,
	Robert.Richter@caviumnetworks.com,
	Aleksey.Makarov@caviumnetworks.com
To: rvatsavayi@caviumnetworks.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Raghu,

your commit f21fb3ed364b ("Add support of Cavium Liquidio ethernet
adapters") is in today's linux-next tree (i.e., next-20150612) adding
the following lines of code:

+config LIQUIDIO
[...]
+       select LIBCRC32

The select turns out to be a NOOP since there is no option LIBCRC32.
I guess it's a typo and the correct option is LIBCRC32C?

Is there a patch queued somewhere to fix the issue?

I detected the issue with ./scripts/checkkconfigsymbols.py.

Kind regards,
 Valentin
