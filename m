From: "Angelo P. Castellani" <angelo.castellani@gmail.com>
Subject: Re: [PATCH 2/2][TCP] YeAH-TCP: limited slow start exported function
Date: Thu, 22 Feb 2007 17:08:37 +0100
Message-ID: <8dd26e70702220808s49a11c03p83da65c164808f52@mail.gmail.com>
References: <45D97D5D.9040101@gmail.com>
	 <20070222.002147.10299202.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrea.baiocchi@uniroma1.it,
	francesco@net.infocom.uniroma1.it
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:54890 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741AbXBVQIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 11:08:38 -0500
Received: by nf-out-0910.google.com with SMTP id o25so568104nfa
        for <netdev@vger.kernel.org>; Thu, 22 Feb 2007 08:08:37 -0800 (PST)
In-Reply-To: <20070222.002147.10299202.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ok, I've missed this bit in the submitting patches documentation..
however sorry for that.

2007/2/22, David Miller <davem@davemloft.net>:
> Please never submit patches like this, submit the infrastructure
> FIRST, then submit the stuff that uses it.  When a sequence of patches
> is applied, in sequence, the tree should build properly (even with all
> available new options enabled) at each step along the way.
>
> Otherwise we have the situation we have now, in that YeaH is in my
> tree but doesn't build successfully.
>
> What I'm going to do to "fix" this, is yank YeaH implementation out
> of my tree, add this second patch first, then add the YeaH patch
> back.
>
> Please never do this again.
>
