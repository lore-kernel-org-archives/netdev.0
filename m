From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] ip multicast route bug fix
Date: Tue, 25 Jul 2006 01:29:37 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0607250128540.15020@d.namei>
References: <20060719145716.4cb9e7e2@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:28883 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932465AbWGYF3l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 01:29:41 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060719145716.4cb9e7e2@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Jul 2006, Stephen Hemminger wrote:

> This should fix the problem reported in http://bugzilla.kernel.org/show_bug.cgi?id=6186
> where the skb is used after freed. The code in IP multicast route.
> 
> Code was reusing an skb which could lead to use after free or double free.
> 
> Signed-off-by: Stephen Hemminger <shemminger@dxpl.pdx.osdl.net>

Acked-by: James Morris <jmorris@namei.org>


-- 
James Morris
<jmorris@namei.org>
