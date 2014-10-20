From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: v3.18-rc1 bloat-o-meter
Date: Mon, 20 Oct 2014 17:57:30 +0200
Message-ID: <CAADnVQJsbNHs-S9gMF7P6FwHvHTfFSTPGNTLXAo5tJ8mpB5t6Q@mail.gmail.com>
References: <alpine.DEB.2.02.1410201018230.24954@ayla.of.borg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-embedded@vger.kernel.org,
	Josh Triplett <josh@joshtriplett.org>,
	Linux Kernel Development <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1410201018230.24954@ayla.of.borg>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 20, 2014 at 10:37 AM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
>         Hi all,
>
> Below is the bloat-o-meter output when comparing an m68k/atari_defconfig
> kernel for v3.17 and v3.18-rc1.
>
> Major culprit seems to be bpf. Can this become modular or optional?
> Currently it's always included if CONFIG_NET=y.

yes, the plan is to get it its own CONFIG_BPF so that tracing wouldn't
need to depend on whole NET and so it can be stubbed out.
