From: md@Linux.IT (Marco d'Itri)
Subject: Re: [RFC] Backward compatibility and WAN netdev configuration
Date: Wed, 1 Feb 2006 15:49:17 +0100
Message-ID: <20060201144917.GA7644@wonderland.linux.it>
References: <m3psm7tksr.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161087AbWBAPRx@vger.kernel.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Content-Disposition: inline
In-Reply-To: <m3psm7tksr.fsf@defiant.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Feb 01, Krzysztof Halasa <khc@pm.waw.pl> wrote:

> a) Currently it consists of mid-layer WAN protocols single module (Cisco
>    HDLC, FR etc.) + low-level hardware HDLC card driver (C101, N2, PCI200SYN
>    etc.). I'm thinking about splitting the protocol module into separate
>    modules - it would make them independent, users would be able to
>    load, say, FR without PPP or X.25 and underlying syncppp, lapb etc.
>    From the technical POV it would be superior to current code but it
>    would require sysadmins to change modprobe.conf, add another modprobe
>    or something like that. Not a real problem but the upgrade can't be
>    automatic.
Why you cannot support autoloading the modules when a specific protocol
is needed?

-- 
ciao,
Marco
