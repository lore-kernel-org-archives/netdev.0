From: jamal <hadi@cyberus.ca>
Subject: Re: Lockup with 2.6.9-ac15 related to netconsole
Date: 22 Dec 2004 08:33:15 -0500
Message-ID: <1103722395.1090.77.camel@jzny.localdomain>
References: <20041221002218.GA1487@electric-eye.fr.zoreil.com>
	 <20041221005521.GD5974@waste.org>
	 <52121.192.102.214.6.1103624620.squirrel@webmail.wetlettuce.com>
	 <20041221123727.GA13606@electric-eye.fr.zoreil.com>
	 <49295.192.102.214.6.1103635762.squirrel@webmail.wetlettuce.com>
	 <20041221204853.GA20869@electric-eye.fr.zoreil.com>
	 <20041221212737.GK5974@waste.org>
	 <20041221225831.GA20910@electric-eye.fr.zoreil.com>
	 <41C93FAB.9090708@trash.net> <41C9525F.4070805@trash.net>
	 <20041222123940.GA4241@electric-eye.fr.zoreil.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, Matt Mackall <mpm@selenic.com>,
	Mark Broadbent <markb@wetlettuce.com>,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261963AbULVNdY@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20041222123940.GA4241@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2004-12-22 at 07:39, Francois Romieu wrote:

> If I am not mistaken, a failure on spin_trylock + the test on
> xmit_lock_owner imply that it is safe to directly handle the
> queue. It means that qdisc_run() has been interrupted on the
> current cpu and the other paths seem fine as well. Counter-example
> is welcome (no joke).

Think more than 2 processors ;-> 

cheers,
jamal
