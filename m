From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] d80211: Only free WEP crypto ciphers when they have
 been allocated correctly.
Date: Wed, 10 Jan 2007 21:14:22 +0100
Message-ID: <20070110211422.1acd6bca@griffin.suse.cz>
References: <459FD5C4.9070301@kpnplanet.nl>
	<200701061229.16632.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Gertjan van Wingerde <gwingerde@kpnplanet.nl>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:36372 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965082AbXAJUOY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jan 2007 15:14:24 -0500
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200701061229.16632.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 6 Jan 2007 12:29:11 -0500, Michael Wu wrote:
> On Saturday 06 January 2007 12:00, Gertjan van Wingerde wrote:
> > The d80211 stack still tries to free the WEP crypto ciphers, even when
> > allocating them previously has failed. 
> Actually, the code might not even have tried to allocate them. The ciphers are 
> guaranteed to be allocated when the device is registered however, so we 
> should be able to free it safely on unregister.

Applied to my tree, thanks for the patch.

 Jiri

-- 
Jiri Benc
SUSE Labs
