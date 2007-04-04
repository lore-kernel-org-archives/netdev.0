From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Silent corruption with r8169
Date: Wed, 4 Apr 2007 20:45:04 +0200
Message-ID: <20070404184504.GB7814@electric-eye.fr.zoreil.com>
References: <20070401012736.GT15189@vitelus.com> <20070401030315.GA24080@jim.sh> <20070401043905.GV15189@vitelus.com> <p737iswqjq4.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Aaron Lehmann <aaronl@vitelus.com>, Jim Paris <jim@jtan.com>,
	linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753967AbXDDStK@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <p737iswqjq4.fsf@bingen.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen <andi@firstfloor.org> :
> Aaron Lehmann <aaronl@vitelus.com> writes:
> 
> [adding netdev]
> [meta-comment: I wish people wouldn't use such unnecessarily broad subjects 
> -- how is it the x86-64 port's or AMD's fault when you have broken hardware? 
> Would anybody write "Silent corruption on i386" or "Silent corruption 
> on Intel" or "Silent corruption on Linux"?]

I hope you feel better now that I changed the subject.

Aaron, I see no clear suspect between 2.6.20.1 and current -git
that could explain nor fix a corruption in the r8169 driver.

Can you apply on top of latest 2.6.21-rc5-git the patches available at
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.21-rc5/r8169-20070402

000[12]-r8169-foo-bar.patch have been committed a few minutes ago: you
should check if they apply or not.

netconsole appears compiled as a module. Is it used ?

-- 
Ueimor
