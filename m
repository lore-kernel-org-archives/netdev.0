From: P@draigBrady.com
Subject: Re: [E1000-devel] e1000 jumbo problems
Date: Wed, 23 Jun 2004 18:35:39 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D9BF6B.4050807@draigBrady.com>
References: <40D883C2.7010106@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: e1000-devel@lists.sourceforge.net
In-Reply-To: <40D883C2.7010106@draigBrady.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

P@draigBrady.com wrote:
> Another related issue, is that the driver uses 4KiB buffers
> for MTUs in the 1500 -> 2000 range which seems a bit silly.
> Any particular reason for that?

I changed the driver to use 2KiB buffers for frames in the
1518 -> 2048 range (BSEX=3D0, LPE=3D1). This breaks however
as packets are not dropped that are larger than the max specified?
Instead they're scribbled into memory causing a lockup after a while.

I noticed in e1000_change_mtu() that adapter->hw.max_frame_size
is only set after e1000_down();e1000_up(); Is that correct?

Are there any anwsers for the general questions I had even?

1. Is there a public dev tree available for the e1000 driver?
2. Are there programming docs for the various GigE chipsets?

thanks,
P=C3=A1draig.
