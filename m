From: Karsten Desler <kdesler@soohrt.org>
Subject: Re: _High_ CPU usage while routing (mostly) small UDP packets
Date: Tue, 7 Dec 2004 05:02:35 +0100
Message-ID: <20041207040235.GA10501@soohrt.org>
References: <20041206224107.GA8529@soohrt.org> <E1CbSf8-00047p-00@calista.eckenfels.6bone.ka-ip.net> <20041207002012.GB30674@quickstop.soohrt.org> <1102387595.1088.48.camel@jzny.localdomain> <20041207025456.GA525@soohrt.org> <1102389533.1089.51.camel@jzny.localdomain> <20041207032438.GA7767@soohrt.org> <1102390241.1093.59.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Bernd Eckenfels <ecki-news2004-05@lina.inka.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261757AbULGECm@vger.kernel.org>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1102390241.1093.59.camel@jzny.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal wrote:
> Beats me. Make sure it boots NAPI. Also if you can turn off ITR; intel
> loves to turn on that silly feature.

ITR was in fact activated. I think i've disabled it now
(e1000.InterruptThrottleRate=0 in the kernel cmdline).
And as I'm reading the e1000 code, there is no way to enable/disable
NAPI without a recompile. So the fact that ethtool spat out -NAPI in
the version string means that NAPI is actually used.

- Karsten
