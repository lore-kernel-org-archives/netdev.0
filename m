From: Thomas Graf <tgraf@suug.ch>
Subject: Re: forwarding of ipv4 link local addresses
Date: Wed, 9 Dec 2015 14:46:34 +0100
Message-ID: <20151209134634.GC11201@pox.localdomain>
References: <565E12BE.90006@cumulusnetworks.com>
 <20151203.143531.282555789343463670.davem@davemloft.net>
 <20151209134416.GB11201@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dsa@cumulusnetworks.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:36777 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753083AbbLINqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 08:46:36 -0500
Received: by wmww144 with SMTP id w144so222979369wmw.1
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 05:46:35 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20151209134416.GB11201@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/09/15 at 02:44pm, Thomas Graf wrote:
> This feature is being used by a popular PaaS which leverages the
> 127/8 address space locally without polluting an entire routeable
> address space.

Kubernetes also wants to rely on this eventually, so please let's
not break it ;-)
