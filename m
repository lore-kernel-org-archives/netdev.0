From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/7] uio: add module owner to prevent inappropriate
 module unloading
Date: Tue, 13 Aug 2013 10:48:14 -0700
Message-ID: <20130813174814.GE4098@kroah.com>
References: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de>
 <1376384922-8519-3-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	"Hans J. Koch" <hjk@hansjkoch.de>,
	Holger Dengler <dengler@linutronix.de>
To: Benedikt Spranger <b.spranger@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:38783 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757276Ab3HMRsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 13:48:16 -0400
Content-Disposition: inline
In-Reply-To: <1376384922-8519-3-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 13, 2013 at 11:08:36AM +0200, Benedikt Spranger wrote:
> If an UIO device is created by another driver (MFD for instance) it has to be
> ensured that the MFD driver isn't removed while the UIO is still in use.

Shouldn't if the MFD driver is removed, the UIO device will be cleaned
up and also removed?  You shouldn't need a module reference for this
type of thing.

And why did I only get 2 of the 7 patches here?

greg k-h
