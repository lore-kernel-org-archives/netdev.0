From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: how to change the initial queue descipline to netem?
Date: Fri, 8 Dec 2006 10:29:39 -0800
Message-ID: <20061208102939.6b76ce4c@localhost>
References: <b7c8741d0612080014i300d7cafj745a661c5ec9829d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:46322 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760819AbWLHS3n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 13:29:43 -0500
To: "Jie Xu" <jiee.xu@gmail.com>
In-Reply-To: <b7c8741d0612080014i300d7cafj745a661c5ec9829d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 8 Dec 2006 16:14:23 +0800
"Jie Xu" <jiee.xu@gmail.com> wrote:

> the main problem is that how to create a netem queue?
> just replace the fifo_fast in dev_activate() failed
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Look at the wiki, you can replace the queue after setting up netem.
	http://linux-net.osdl.org/index.php/Netem
The initial default is a variant of FIFO with time ordering.
