From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Lockup with 2.6.9-ac15 related to netconsole
Date: Tue, 21 Dec 2004 21:48:53 +0100
Message-ID: <20041221204853.GA20869@electric-eye.fr.zoreil.com>
References: <34721.192.102.214.6.1103274614.squirrel@webmail.wetlettuce.com> <20041217215752.GP2767@waste.org> <20041217233524.GA11202@electric-eye.fr.zoreil.com> <36901.192.102.214.6.1103535728.squirrel@webmail.wetlettuce.com> <20041220211419.GC5974@waste.org> <20041221002218.GA1487@electric-eye.fr.zoreil.com> <20041221005521.GD5974@waste.org> <52121.192.102.214.6.1103624620.squirrel@webmail.wetlettuce.com> <20041221123727.GA13606@electric-eye.fr.zoreil.com> <49295.192.102.214.6.1103635762.squirrel@webmail.wetlettuce.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mpm@selenic.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261852AbULUUwv@vger.kernel.org>
To: Mark Broadbent <markb@wetlettuce.com>
Content-Disposition: inline
In-Reply-To: <49295.192.102.214.6.1103635762.squirrel@webmail.wetlettuce.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Broadbent <markb@wetlettuce.com> :
[...]
> Using the patch supplied I get no hang, just the message 'netconsole
> raced' output to the console and the packet capture proceeds as normal.
> Thanks

The patch is more a bandaid for debugging than a real fix. The netconsole
will drop some messages until its locking is fixed

If you can issue one more test, I'd like to know if some messages appear
on the VGA console around the time at which tcpdump is started (the test
assumes that netconsole is not used/insmoded at all). Please check that
the console log_level is set high enough as it will be really disappointing
if nothing appears :o)

--
Ueimor
