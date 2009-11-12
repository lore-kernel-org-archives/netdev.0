From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] rps: changes to bnx2x to get device hash
Date: Wed, 11 Nov 2009 18:42:09 -0800 (PST)
Message-ID: <20091111.184209.197449129.davem@davemloft.net>
References: <65634d660911102253lbfc0927i4e4c0eba6d7d765d@mail.gmail.com>
	<20091111232103.GA1217@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58872
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759938AbZKLClm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 21:41:42 -0500
In-Reply-To: <20091111232103.GA1217@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Wed, 11 Nov 2009 15:21:03 -0800

> Is a random hash key really better than arbitrary static values?  
> Setting the hash key to random values means, from chip reset to chip
> reset, you could get different performance results.  Unless we
> we understood how the key affects performance, I would think that
> reproducable performance numbers would be more desirable, no?

Security.

If someone knows the key and the hash function, they can purposely
pick address and port combinations that always hash to the same queue,
decresing your horsepower to handle traffic by orders of magnitude.
