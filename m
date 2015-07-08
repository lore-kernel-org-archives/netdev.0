From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: [PATCH V2] cdc_ncm: Add support for moving NDP to end of NCM
 frame
Date: Wed, 8 Jul 2015 13:15:41 +0200 (CEST)
Message-ID: <alpine.LNX.2.20.1507081311130.2014@localhost.localdomain>
References: <1435787748-30393-1-git-send-email-mrkiko.rs@gmail.com> <alpine.LNX.2.20.1507051219280.12595@archiso.lan> <1436177296.8225.25.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	chrono <chrono@open-resource.org>
To: Oliver Neukum <oneukum@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:33015 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758337AbbGHLPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 07:15:47 -0400
In-Reply-To: <1436177296.8225.25.camel@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Oliver and everybody reading this message.

So V3 of this patch fixed the issue I reported recently.
I wasn't properly accounting for the NDP size when writing new packets to the 
SKB: so i ended up writing past the end of SKB buffer.

Thank you for your patience and help.
Enrico
