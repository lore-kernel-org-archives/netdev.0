From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [2.6.16-gitX] heavy performance regression in ipw2200 wireless
	driver
Date: Fri, 24 Mar 2006 11:41:14 +0800
Message-ID: <1143171674.17270.195.camel@debian.sh.intel.com>
References: <5a4c581d0603221724m391f5466l8a2af3ae7f0aacae@mail.gmail.com>
	 <20060322191057.304962a4.akpm@osdl.org>
	 <5a4c581d0603230602s1a868a4apbfd79ec2bc568011@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	James Ketrenos <jketreno@linux.intel.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422691AbWCXDrp@vger.kernel.org>
To: Alessandro Suardi <alessandro.suardi@gmail.com>
In-Reply-To: <5a4c581d0603230602s1a868a4apbfd79ec2bc568011@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-03-23 at 15:02 +0100, Alessandro Suardi wrote:
> That scp test shows 50%ish - but that was a quickie. The VNC
>  client even reported a 719Kbps throughput down from the more
>  usual 11500Kbps it starts off with. The first scp I tried when the
>  sluggishness was intolerable was going at 200KB/s - which
>  shows the problem can easily get in the neighborhood of an
>  order of magnitude.

What kind of wireless encryption do you use? We turned off hardware
encryption by default recently as a workaround for a firmware restart
bug. You might want to load module with "modprobe ipw2200 hwcrypto=1"
and retest.

Thanks,
-yi
