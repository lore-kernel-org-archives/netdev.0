From: "Chad N. Tindel" <chad@tindel.net>
Subject: Re: [bonding] compatibilty issues
Date: Mon, 29 Sep 2003 19:25:34 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030929232534.GB93323@calma.pair.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="k+w/mQv8wyuph6w0"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--k+w/mQv8wyuph6w0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Forwarding, as I forgot to include the list on the original 
distribution.

Chad

--k+w/mQv8wyuph6w0
Content-Type: message/rfc822
Content-Disposition: inline

Date: Mon, 29 Sep 2003 19:24:44 -0400
From: "Chad N. Tindel" <chad@tindel.net>
To: Jeff Garzik <jgarzik@pobox.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>, "Hen, Shmulik" <shmulik.hen@intel.com>,
	"Noam, Amir" <amir.noam@intel.com>,
	"Mendelson, Tsippy" <tsippy.mendelson@intel.com>,
	"Marom, Noam" <noam.marom@intel.com>
Subject: Re: [bonding] compatibilty issues
Message-ID: <20030929232444.GA93323@calma.pair.com>
References: <20030929185202.GB31128@calma.pair.com> <200309291925.h8TJPRab025832@death.ibm.com> <20030929193208.GB24740@gtf.org> <20030929215842.GA77637@calma.pair.com> <3F78B4E7.2070205@pobox.com> <20030929230607.GA88685@calma.pair.com> <3F78BC9D.3090103@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3F78BC9D.3090103@pobox.com>
User-Agent: Mutt/1.4i

> Chad N. Tindel wrote:
> >2.  Once a user upgrades to 2.6, they forego all hope of forward 
> >compatibility.
> >They may be required to upgrade ifenslave. 
> 
> Not correct.  When I am testing patches people send to me, I am 
> literally booting back and forth into 2.4 and 2.6 on an hour-by-hour 
> basis.  2.4 ifenslave must continue to work under a 2.6 kernel.

This directly contradicts what I was told by David Miller when we first
integrated bonding into 2.4 back in the 2.4.9 timeframe.  So, what I would
like from you then is a statement saying for how long this support must
continue.  Does the 2.8 ifenslave have to work for 2.4?  Or is it simply
an off by one problem?  That is, 2.8 ifenslave will have to work for 
a 2.6 kernel as well, but no more?  

Are all the other utilities having to do this too?  raidhotadd will continue
to work both for 2.4 and 2.6?  

> Rusty tried this with module-init-tools, and it's a yucky solution.  For 
> this case, Red Hat updated the modutils package to support both 2.4 and 
> 2.6 kernels out of the box, same userland.

I agree its a yucky solution, but its better than saying that the Linux
Kernel 4.6 version of ifenslave has to work for all prior versions of 
bonding (2.4, 2.6, 3.0, 3.8, 4.0 etc..).  And it also seems better from
a code stability point of view too... I mean, if all we had some was scripting
nastiness and it meant that because our code in newer kernels was simpler, 
leaner, easier to work with and debug... that would seem like the proper
tradeoff to make.  No?

Chad

--k+w/mQv8wyuph6w0--
