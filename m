From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH 7/32] rt2x00: make vals static
Date: Fri, 28 Apr 2006 13:26:43 +0200
Message-ID: <200604281326.43769.netdev@axxeo.de>
References: <200604280002.58147.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:29841 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S965022AbWD1L0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 07:26:55 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200604280002.58147.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sie schrieben:
> From: Ivo van Doorn <IvDoorn@gmail.com>
> 
> The vals[] arrays in *_init_hw_channels can be made
> static to optimize memory and reduce stack size.

What about static const? They are also constants, right?
But please try first, if this helps in terms of code size.

Regards

Ingo Oeser
