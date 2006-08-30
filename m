From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Loop detected  - calling function from different modules
Date: Wed, 30 Aug 2006 14:26:07 -0700
Message-ID: <20060830142607.31c858cd@localhost.localdomain>
References: <BAY101-F5AD1ED322334DFDAC9F22AB3E0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:32201 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932085AbWH3V0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 17:26:09 -0400
To: "Frank Schneider" <twodipu@hotmail.com>
In-Reply-To: <BAY101-F5AD1ED322334DFDAC9F22AB3E0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 30 Aug 2006 22:58:17 +0200
"Frank Schneider" <twodipu@hotmail.com> wrote:

> 
> hi all,
> 
> I am writing/customizing a network(wlan pc card) device driver for Linux 
> kernel 2.6.12
> Think about I have two modules e.g. ath_pci and wlan module.
> I can call a function from a   .c file which is implemented in a  .c file in 
> wlan module by using EXPORT_SYMBOL macro..
> 
> and i need to do same in reverse way, i.e. call a function from wlan module 
> that is implemented in ath_pci module.
> 
> I did the same way and its making but when I do  make install its showing 
> following error:
> 
> WARNING: Loop detected: /lib/modules/2.6.12/net/ath_pci.ko needs wlan.ko 
> which needs ath_pci.ko again!
> 
> Please anybody tell how can I do this, any clue , please ?
> 
> thanx in advance
> 
> n.b. this question may consider as very naive since I am not good yet in 
> kernel hacking.. !!!!
> 
> regards,
> /Frank

Where are these open source drivers so the wireless developers can help?

-- 
Stephen Hemminger <shemminger@osdl.org>
