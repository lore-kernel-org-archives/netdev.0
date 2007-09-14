From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [git patches] net driver fixes
Date: Fri, 14 Sep 2007 14:17:45 -0400
Message-ID: <46EAD049.4020107@garzik.org>
References: <20070913053022.GA16891@havoc.gtf.org> <1189793598.2508.4.camel@xo-3E-67-34.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756759AbXINSSH@vger.kernel.org>
In-Reply-To: <1189793598.2508.4.camel@xo-3E-67-34.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Williams wrote:
> WTF?  why would the default be to _not_ propagate carrier state?  Are
> there some mitigating circumstances that require this driver to not
> notify the stack of carrier on/off?  Userspace stuff really should know
> about the carrier state, and this disables it by default.


The commit explains that...

	Jeff
