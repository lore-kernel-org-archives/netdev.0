From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: network namespace and kernel bind issue
Date: Mon, 1 Oct 2012 16:32:26 -0700
Message-ID: <20121001163226.3873ca58@nehalam.linuxnetplumber.net>
References: <20121001141609.14639bc0@nehalam.linuxnetplumber.net>
	<20121001145838.5eafef4c@nehalam.linuxnetplumber.net>
	<87fw5xeryf.fsf@xmission.com>
	<20121001155702.5b5e2188@nehalam.linuxnetplumber.net>
	<87y5jpdbzo.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42086 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753558Ab2JAXdC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2012 19:33:02 -0400
In-Reply-To: <87y5jpdbzo.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 01 Oct 2012 16:11:07 -0700
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Then my guess is that you have an ordering problem.  Attempting
> to initialize a vxlan before ipv4 is initialized or some such.

Isn't there a gurantee that init operations are called in the order
they registered?
