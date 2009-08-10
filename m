From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: Serialize access to PCI config space
Date: Mon, 10 Aug 2009 08:23:15 -0700
Message-ID: <20090810082315.16b7a0b9@nehalam>
References: <4A7EB4EF.3030106@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35656 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750780AbZHJPXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 11:23:50 -0400
In-Reply-To: <4A7EB4EF.3030106@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 09 Aug 2009 20:37:19 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> 
> Disable NAPI when powering up or down the phy, as sky2_err_intr
>  may also access the PCI config space.

Maybe, but any sky2_err interrupt is a serious condition that
means hardware is being used incorrectly or dead.
