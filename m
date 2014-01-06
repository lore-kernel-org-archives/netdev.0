From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: Re: Possible to add netfilter hooks to IFB driver?
Date: Mon, 6 Jan 2014 17:18:08 +0000
Message-ID: <20140106171808.7f491286@rainbow.cbg.collabora.co.uk>
References: <522653F1.6090902@ecessa.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brad Johnson <bjohnson@ecessa.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.135.160]:60190 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755259AbaAFRSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 12:18:11 -0500
In-Reply-To: <522653F1.6090902@ecessa.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 03 Sep 2013 16:26:09 -0500
Brad Johnson <bjohnson@ecessa.com> wrote:

> I would like to add netfilter hooks to the IFB driver so I can do 
> iptables -j IFB (just like we can with IMQ). But I would like to know 
> first if there are any reasons this can not work. Please advise if
> this is possible, and if so any tips would be appreciated.

I would like to have the same feature for ingress shaping via
connection marking. But this page says "wont go back to putting
netfilter hooks" but have a "contrack related action":
http://www.linuxfoundation.org/collaborate/workgroups/networking/ifb
http://thread.gmane.org/gmane.linux.network/21224

I don't know if someone made a patch for either implementation.

Best regards,
Alban
