From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] chelsio 10G (T1/T2)
Date: Tue, 5 Dec 2006 11:58:30 -0800
Message-ID: <20061205115830.2d55a54e@freekitty>
References: <8A71B368A89016469F72CD08050AD334DA55F1@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:49340 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030827AbWLET7R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 14:59:17 -0500
To: "Felix Marti" <felix@chelsio.com>
In-Reply-To: <8A71B368A89016469F72CD08050AD334DA55F1@maui.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 5 Dec 2006 10:53:10 -0800
"Felix Marti" <felix@chelsio.com> wrote:

> T1's and T2's implementation of MSI has a bug. I believe to remember
> that it 
> 
> works with some chipsets but we should disable MSI by default.


Is this really the platform bug, if so it should be handled by the pci quirks
already. Or is this a Chelsio hardware bug?
