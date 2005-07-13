From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [05/11] SMP fix for 6pack driver
Date: Thu, 14 Jul 2005 00:01:23 +0200
Message-ID: <20050713220123.GA3292@electric-eye.fr.zoreil.com>
References: <20050713184130.GA9330@kroah.com> <20050713184331.GG9330@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ralf@linux-mips.org, netdev@vger.kernel.org, jgarzik@pobox.com,
        linux-kernel@vger.kernel.org, stable@kernel.org,
        Justin Forbes <jmforbes@linuxtx.org>,
        Zwane Mwaikambo <zwane@arm.linux.org.uk>,
        "Theodore Ts'o" <tytso@mit.edu>, "Randy.Dunlap" <rdunlap@xenotime.net>,
        Chuck Wolber <chuckw@quantumlinux.com>, torvalds@osdl.org,
        akpm@osdl.org, alan@lxorguk.ukuu.org.uk
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262224AbVGMWYE@vger.kernel.org>
To: Greg KH <gregkh@suse.de>
Content-Disposition: inline
In-Reply-To: <20050713184331.GG9330@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greg KH <gregkh@suse.de> :
> -stable review patch.  If anyone has any objections, please let us know.
> 
> ------------------
> 
> 
> Drivers really only work well in SMP if they actually can be selected.
> This is a leftover from the time when the 6pack drive only used to be
> a bitrotten variant of the slip driver.

Is the guideline above from 28/04/2005 obsoleted ?

 - It must fix a problem that causes a build error (but not for things
   marked CONFIG_BROKEN), an oops, a hang, data corruption, a real
   security issue, or some "oh, that's not good" issue.  In short,
   something critical.

--
Ueimor
