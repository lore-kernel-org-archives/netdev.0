From: Larry Finger <larry.finger@lwfinger.net>
Subject: Re: [PATCH 2.6.19-git19] BUG due to bad argument to ieee80211softmac_assoc_work
Date: Thu, 14 Dec 2006 18:47:15 -0600
Message-ID: <4581F093.3020806@lwfinger.net>
References: <5b8e20700612131017n1cd8aff3qbe41351435427e25@mail.gmail.com>	 <341A1CE8-DF10-4CD5-B675-89449256EAB5@deine-taler.de> <5b8e20700612141348l66af58b6lb6899b710d1d9c14@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Uli Kunitz <kune@deine-taler.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932635AbWLOArh@vger.kernel.org>
To: Michael Bommarito <michael.bommarito@gmail.com>
In-Reply-To: <5b8e20700612141348l66af58b6lb6899b710d1d9c14@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Bommarito wrote:
> Hello Uli,
>  Yes, apologies, I had been waiting for an abandoned bugzilla entry
> to get attention, and when I realized it was assigned to a dead-end, I
> had simply posted the patch without checking for prior messages.
>  I was further confused by the fact that it hadn't made its way into
> any of the 19-gitX sets (and for that matter, the window for
> 2.6.20-rc1 has come and gone and this still remains unfixed), despite
> how clear the error was and how trivial the fix seems.

I was not aware that a bugzilla entry existed for this problem. I learned about it when my system 
would hang on bootup if the bcm43xx card was installed. By bisection, I learned which commit was 
causing the problem. About that time, the complete fix was discussed on the netdev and bcm43xx 
mailing lists. I was a little perturbed that only part of the fix was accepted into 2.6.19-gitX.

The full fix was pushed to John Linville on Dec. 10, who pushed it on to Jeff Garzik on Dec. 11. I 
have not yet seen any message sending it on to Andrew Morton or Linus.

A bug fix will always be accepted, particularly one that only changes 2 lines - it is only a new 
feature that will no longer be accepted once the -rc1 stage is reached. If this message doesn't do 
the trick and it isn't included by -rc2, I'll ping Jeff to see what happened. Changes always take 
longer than one likes, but one needs to be careful.

Larry
