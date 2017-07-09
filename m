From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] of_mdio: Fix broken PHY IRQ in case of probe deferral
Date: Sun, 9 Jul 2017 19:28:15 +0200
Message-ID: <20170709172815.GA28183@lunn.ch>
References: <1495112345-24795-1-git-send-email-geert+renesas@glider.be>
 <f0ed61c3-062b-cec6-fe19-7412231e8ef1@gmail.com>
 <CAMuHMdWYeSzofU57LmT_M3KkcHhvjfJy7nkHvcXkKzOYmvhqqA@mail.gmail.com>
 <20170518193453.GB13759@lunn.ch>
 <CAMuHMdV+jfh=EGt3SvjtrtVfWQ6P8ofp_JxeQZjRrSEfDWs5hA@mail.gmail.com>
 <08a89dd5-b707-8b8f-b8e1-e20b9ed630b7@gmail.com>
 <CAMuHMdWWfaP8=H7H+UzrmOYpydi2mGLFGzuk9FQWJtEOug6u5g@mail.gmail.com>
 <CAMuHMdUt6yOQ9=02z_7WG58YGxFYD=_zn7SeLEqGmfTrNBFJXw@mail.gmail.com>
 <CAMuHMdW8yzREzTE4GiW_8HU9h-T-fdDmLtZAXYkJrjuypN8BDg@mail.gmail.com>
 <38cc7c65-e4ca-cb8a-f43b-ca53e87724cf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <38cc7c65-e4ca-cb8a-f43b-ca53e87724cf@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> It sure does fix a real issue, but I am really concerned about the
> inability to test this patch in a configuration where we have multiple
> PHY(s) or MDIO device(s) hanging off the same MDIO bus and one of those
> requesting an EPROBE_DEFER.
> 
> I currently don't have a setup where I could exercise this, Andrew, do you?

Hi Florian

What i do have, is a switch with some built in copper Marvell PHYs and
external SFF modules which use fixed link. I can probably hack the
fixed-link driver to return EPROBE_DEFER a few times.

	   Andrew
