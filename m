From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 2.6.9-rc1-bk11+ and 2.6.9-rc1-mm3,4 r8169: freeze during boot (FIX included)
Date: Mon, 20 Sep 2004 09:17:43 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040920071743.GA7115@electric-eye.fr.zoreil.com>
References: <200409130035.50823.hfvogt@arcor.de> <20040916070211.GA32592@electric-eye.fr.zoreil.com> <200409161320.16526.jdmason@us.ltcfwd.linux.ibm.com> <200409171043.21772.jdmason@us.ltcfwd.linux.ibm.com> <20040917160151.GA29337@electric-eye.fr.zoreil.com> <414DF773.7060402@myrealbox.com> <20040919213952.GA32570@electric-eye.fr.zoreil.com> <414E46F1.9050309@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@myrealbox.com>,
	Hans-Frieder Vogt <hfvogt@arcor.de>,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S266127AbUITHTs@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <414E46F1.9050309@pobox.com>
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> :
[...]
> That sounds like a bug right there...  need all the addresses set up 
> before we turn on stuff.

The description of the CPlusCmd in the 8169 datasheet includes a small note
which suggests that this register should be set up early.

It does not cost much to try and see if it makes a difference for DAC though.

--
Ueimor
