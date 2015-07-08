From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: [PATCH V2] cdc_ncm: Add support for moving NDP to end of NCM
 frame
Date: Wed, 8 Jul 2015 09:54:02 +0200 (CEST)
Message-ID: <alpine.LNX.2.20.1507080949470.1204@localhost.localdomain>
References: <1435787748-30393-1-git-send-email-mrkiko.rs@gmail.com> <alpine.LNX.2.20.1507051219280.12595@archiso.lan> <1436177296.8225.25.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: Enrico Mioso <mrkiko.rs@gmail.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:34802 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964814AbbGHHyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 03:54:07 -0400
In-Reply-To: <1436177296.8225.25.camel@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So, here is what I tried so far:
1 - Check if the pointer gets corrupted somehow (address change): it seems this 
doesn't happen at all.
2 - Size problems: I tried setting higher values of the size just in case, with 
absolutely no changei n behaviour.

The code that assigns the pointer the address returned by kzalloc is after all 
the other function invocations in _bind(), so I don't know where to look 
exactly.
