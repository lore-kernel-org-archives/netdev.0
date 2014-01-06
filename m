From: Julia Lawall <julia.lawall@lip6.fr>
Subject: question about ti/tlan.c
Date: Mon, 6 Jan 2014 11:09:35 +0100 (CET)
Message-ID: <alpine.DEB.2.10.1401061107020.2079@hadrien>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: chessman@tux.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:10861 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752652AbaAFKJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 05:09:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the function tlan_suspend, I wonder if the following code is correct?

pci_wake_from_d3(pdev, false);

I have only a moderate understanding of the code, but it seems odd that
both the suspend function and the resume function turn off wakeup events.

julia
