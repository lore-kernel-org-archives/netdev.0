From: Arjan van de Ven <arjan@fenrus.demon.nl>
Subject: Re: [patch 2.6.9 0/11] Add MODULE_VERSION to several network
	drivers
Date: Thu, 21 Oct 2004 15:46:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098366370.2810.31.camel@laptop.fenrus.com>
References: <20041020141146.C8775@tuxdriver.com>
	 <1098350269.2810.17.camel@laptop.fenrus.com>
	 <20041021082205.A29340@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, jgarzik@pobox.com,
        davem@davemloft.net, john.ronciak@intel.com,
        ganesh.venkatesan@intel.com, akpm@osdl.org, romieu@fr.zoreil.com,
        ctindel@users.sourceforge.net, fubar@us.ibm.com,
        greearb@candelatech.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20041021082205.A29340@tuxdriver.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-10-21 at 14:22, John W. Linville wrote:
>  
> > have you checked if the version of these drivers is actually useful? (eg
> > updated when the driver changes) If it's not I'd say adding a
> > MODULE_VERSION to it makes no sense whatsoever.
> 
> Why do I feel like I'm being baited...? :-)
> 
> I would have to suspect that if a version string exists, that it has at
> least some meaning to the primary developers/maintainters.  It certainly
> is beyond my control to force the maintainers to give meaning to their
> version strings.

Since the skeleton driver includes a define for that, I suspect your
assumption is a bit overly optimistic. 

> Is this a political statement against the MODULE_VERSION macro and/or
> its purpose?  I'm not overly interested in debating that one...

Not really. I have absolutely no problem with a MODULE_VERSION macro
*IF* the version it advertises means something. However if the version
it advertises has no meaning whatsoever (eg the version number never
gets updated) then imo it's better to NOT advertise anything so that
other tools (like dkms) don't make assumptions and decisions based on
nothing-meaning data.
