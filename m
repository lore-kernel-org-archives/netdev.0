From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] /driver/net/wan/sbs520
Date: Mon, 10 Jan 2005 19:00:52 +0100
Message-ID: <20050110180052.GA27528@electric-eye.fr.zoreil.com>
References: <4F23E557A0317D45864097982DE907941A32B1@pilotmail.sbscorp.sbs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Adam Anthony <AAnthony@sbs.com>
Content-Disposition: inline
In-Reply-To: <4F23E557A0317D45864097982DE907941A32B1@pilotmail.sbscorp.sbs.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Adam Anthony <AAnthony@sbs.com> :
[...]
>        It would be great to receive some feedback on our work, and we hope
> that this driver will eventually be added to the kernel.

It will probably require a few extra steps:
- read Documentation/CodingStyle (mixed case, typedef from hell, ugly #ifdef);
- grep ^static
  -> no static functions ? Uh ?
- use non-obsolete API (pci_find_device in 2005 ?);
- convert the os independant wrappers.

Btw it would probably make sense 1) to figure out what can be merged with
the in-tree DSCC4 driver and 2) to integrate the driver with the existing
hdlc stack. Imho there is some duplicated work/code.

--
Ueimor
