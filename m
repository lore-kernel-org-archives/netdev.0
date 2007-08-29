From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/1][RFC] add a private field to the sock structure
Date: Wed, 29 Aug 2007 11:23:16 -0700 (PDT)
Message-ID: <20070829.112316.98862875.davem@davemloft.net>
References: <20070829164114.868188182@f002726.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60475
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751804AbXH2SXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 14:23:17 -0400
In-Reply-To: <20070829164114.868188182@f002726.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: dlezcano@fr.ibm.com
Date: Wed, 29 Aug 2007 18:41:14 +0200

> When a socket is created it is sometime useful to store a specific information
> for this socket.
>  
> This information can be for examples: 
> 	* a creation time
> 	* a pid
> 	* a uid/gid
> 	* a container identifier
> 	* a pointer to a more specific structure
> 	* ...
> 
> The following patch is a proposition to add a private anonymous pointer
> field to the common part of the sock structure.

We got rid of the private field a long time ago because not only
is it not needed, it tends to get abused.

Find another way to implement your feature.
