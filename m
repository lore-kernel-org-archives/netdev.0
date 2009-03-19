From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Question: igmp behavior on interface change
Date: Wed, 18 Mar 2009 22:34:52 -0400
Message-ID: <20090319023452.GA27155@localhost.localdomain>
References: <20090318140353.GA9771@hmsreliant.think-freely.org> <OF69D34007.7F9590E4-ON8825757D.005914BF-8825757D.00592A56@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andy@greyhouse.net, davem@davemloft.net, netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42447 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751638AbZCSCfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 22:35:07 -0400
Content-Disposition: inline
In-Reply-To: <OF69D34007.7F9590E4-ON8825757D.005914BF-8825757D.00592A56@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 18, 2009 at 09:13:55AM -0700, David Stevens wrote:
> 
> 
> Neil Horman <nhorman@tuxdriver.com> wrote on 03/18/2009 07:03:53 AM:
> 
> 
> >    I was going to look into writing some notification code for igmp to
> > detect link state chagnes and issue the reports on link up, but I wanted
> to be
> > sure there were no counter arguments first.  So any and all thoughts
> > appreciated.
> 
>       Isn't that ip_mc_up()? Are you not getting the reports?
> 
>                                                 +-DLS

Thank you!  I knew there was a some integration between igmp and interface state
changes, but couldn't find it!  Nevertheless, yes, thats the report I'm getting,
not so much the lack of membership reports, but the lack of multicast reception
in perpituity after a link state change.  I'm still gathering data on why, so
I'm not 100% sure on the lack of the membership report, but now that you've
shown me the path between state changes and igmp updates, I can figure out more
precisely whats going on.

Thanks!
Neil

