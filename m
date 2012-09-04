From: Micha Nelissen <micha@neli.hopto.org>
Subject: Re: Commit "ipconfig wait for carrier" makes boot hang for 2 mins
 if no  carrier
Date: Tue, 04 Sep 2012 21:33:37 +0200
Message-ID: <50465791.40805@neli.hopto.org>
References: <504627A4.9080306@neli.hopto.org>,	<OF61EF9E6E.9EF08C21-ONC1257A6F.004FE9B4-C1257A6F.0050A9B2@transmode.se> <OF163B52E3.E2F5ACB3-ONC1257A6F.00635561-C1257A6F.00635564@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isp-bos-02.edutel.nl ([88.159.1.183]:55095 "EHLO
	isp-bos-02.edutel.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757568Ab2IDTdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 15:33:42 -0400
In-Reply-To: <OF163B52E3.E2F5ACB3-ONC1257A6F.00635561-C1257A6F.00635564@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joakim Tjernlund wrote:
>>  Why not set the IP address then in your rootfs yourself?  Micha 
> 
> I could ask you the same question, why do you need to have nfs in kernel?

Because that's where my root filesystem is? The IP autoconfiguration
code exists for this purpose.

> The answer is probably the same, it is much easier to
> manage our IP config in one place for our embedded system.

You retrieve the kernel via TFTP or so when booting?

> I don't understand why you need 2 minutes timeout for carrier either?

Just a safe value.

> The wait should be conditional on NFS root or not so that non NFS roots
> can skip this stage altogether.

Feel free to submit a patch :-)

Micha
