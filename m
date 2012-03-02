From: Gustavo Padovan <padovan@profusion.mobi>
Subject: Re: pull request: bluetooth-next 2012-03-01
Date: Fri, 2 Mar 2012 13:37:16 -0300
Message-ID: <20120302163716.GA18758@joana>
References: <20120302025554.GA13493@joana>
 <20120301.221643.881299898523907213.davem@davemloft.net>
 <20120301.222316.1877216960521396397.davem@davemloft.net>
 <20120301.222604.1508242694024394849.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gustavo@padovan.org, johan.hedberg@gmail.com,
	linville@tuxdriver.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:38997 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758838Ab2CBQh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2012 11:37:26 -0500
Received: by vbbff1 with SMTP id ff1so1635082vbb.19
        for <netdev@vger.kernel.org>; Fri, 02 Mar 2012 08:37:25 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20120301.222604.1508242694024394849.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

* David Miller <davem@davemloft.net> [2012-03-01 22:26:04 -0500]:

> From: David Miller <davem@davemloft.net>
> Date: Thu, 01 Mar 2012 22:23:16 -0500 (EST)
> 
> > From: David Miller <davem@davemloft.net>
> > Date: Thu, 01 Mar 2012 22:16:43 -0500 (EST)
> > 
> >> This was only three commits into your tree, therefore I'm not very
> >> optimistic to be honest with you.
> > 
> > In the very next commit, 3175405b906a85ed2bad21e09c444266e4a05a8e we end
> > up with:
> 
> And then 2 commits later in ff9ef5787046c3fd20cf9f7ca1cd70260c1eedb9:
> 
> +	if (hdev->discovery.state != DISCOVERY_STOPPED) {
> +		err = cmd_status(sk, index, MGMT_OP_START_DISCOVERY,
> +						MGMT_STATUS_BUSY);
> +		goto failed;
> +	}
> 
> it must be isntead:
> 
> 		err = cmd_status(sk, index, MGMT_OP_START_DISCOVERY,
> 				 MGMT_STATUS_BUSY);
> 
> And that's pretty much as far as I'm willing to go.
> 
> You know what really pisses me off?  This is the one issue I made a huge
> stink about last week, arguments to function calls and prototypes lining
> up properl.  And it's in ever 2nd or 3rd commit in this pull request.

The styles in these patches is the same style we've been using in Bluetooth
code for more than 10 years and no one ever complained to us and we are the
only subsystem under Net doing something like this. I could find some examples
over the net code in a quick look.

I can see only two options here, leave this as is since this is coding style
we've been using since beginning or change the whole Bluetooth subsystem to
work like you said. In other words, are you telling me to make a patch to fix
this issue in the whole Bluetooth subsystem and not only in this pull request
diff? Otherwise we are putting the Bluetooth code in a inconsistent state with
two different coding styles. Is that what you want, an inconsistent state?

I'd be ok with changing the whole subsystem's style if you want.

	Gustavo
