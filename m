From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] act_mirred: don't go back.
Date: Tue, 10 Nov 2009 02:40:34 -0500
Message-ID: <1257838834.3647.4.camel@bigi>
References: <4AF7B9F4.6010507@gmail.com> <1257751376.8009.2.camel@bigi>
	 <412e6f7f0911090031j16ab9c73o47f4d4d3ffd9be3a@mail.gmail.com>
	 <1257764086.6246.1.camel@bigi>
	 <412e6f7f0911090433j2b270663ycdf277110fbc6bac@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:41078 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751802AbZKJHka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 02:40:30 -0500
Received: by yxe17 with SMTP id 17so3267172yxe.33
        for <netdev@vger.kernel.org>; Mon, 09 Nov 2009 23:40:35 -0800 (PST)
In-Reply-To: <412e6f7f0911090433j2b270663ycdf277110fbc6bac@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I apologize - I am still not convinced this is a cleanup and i can
already see holes you are introducing (example not freeing skb etc). 
You are putting me in a dilemma of not wanting to discourage you
but at the same time not seeing this as a useful change to be made.
Can we let this one slide?

cheers,
jamal

On Mon, 2009-11-09 at 20:33 +0800, Changli Gao wrote:

[..]
> How about this version.
> 
> 1. move skb_act_clone() after all the necessary checks, and it can
> eliminate unnecessary skb_act_clone() if tcfm_eaction isn't correct.
> 2. there is one exit of the critical section.
> 3. jump forward instead of backward.


