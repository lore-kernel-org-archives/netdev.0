From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] 2.6.0-test9-bk27-netdrvr-exp1 - r8169 update
Date: Mon, 24 Nov 2003 22:34:59 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031124223459.A11435@electric-eye.fr.zoreil.com>
References: <20031122183001.GA16993@gtf.org> <20031124000939.A456@electric-eye.fr.zoreil.com> <3FC14058.4010600@mcve.com> <20031124004023.A1140@electric-eye.fr.zoreil.com> <3FC14AA3.9050009@mcve.com> <20031124090421.A4482@electric-eye.fr.zoreil.com> <3FC21843.2080805@mcve.com> <20031124184908.A9566@electric-eye.fr.zoreil.com> <3FC24C2B.1030007@mainstreetsoftworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Brad House <brad@mainstreetsoftworks.com>
Content-Disposition: inline
In-Reply-To: <3FC24C2B.1030007@mainstreetsoftworks.com>; from brad@mainstreetsoftworks.com on Mon, Nov 24, 2003 at 01:21:31PM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Brad House <brad@mainstreetsoftworks.com> :
> Yes, I can do that.  These are the patches I applied:
> -ftp://ftp.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/2.6.0-test9-bk25-netdrvr-exp1.patch.bz2
> -r8169-mac-phy-version.patch
[...]
> Let me know where to begin, and I'll do it.

You patch -R in the following order until you get the behavior of vanilla
kernel (or return to vanilla and patch in reverse order but you will notice
a small reject for rx_copybreak due to an inserted GPL_MODULE in -netdrvr-exp).
- r8169-mac-phy-version.patch
- r8169-rx_copybreak.patch (11/22/2003 in euroland)
- r8169-dma-api-tx-buffers.patch
- r8169-start-xmit-fixes.patch
- r8169-dma-api-data-buffers.patch
- r8169-dma-api-tx.patch 

1 - If you don't get the usual behavior at this point, something is _wrong_.
2 - You will have a one line offset, don't worry.

Thank you.

--
Ueimor
