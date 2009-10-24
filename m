From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch next 3/4] netxen: fix bonding support
Date: Fri, 23 Oct 2009 19:13:01 -0700
Message-ID: <m1skd9letu.fsf@fess.ebiederm.org>
References: <1241586309-12112-1-git-send-email-dhananjay@netxen.com>
	<1241586309-12112-4-git-send-email-dhananjay@netxen.com>
	<m1ljj2ps80.fsf@fess.ebiederm.org>
	<7608421F3572AB4292BB2532AE89D5658B0B6E4F72@AVEXMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:57473 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbZJXCM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 22:12:57 -0400
In-Reply-To: <7608421F3572AB4292BB2532AE89D5658B0B6E4F72@AVEXMB1.qlogic.org> (Dhananjay Phadke's message of "Fri\, 23 Oct 2009 18\:54\:35 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dhananjay Phadke <dhananjay.phadke@qlogic.com> writes:

> Yes, this was a bug until recent times.
>
> It should be fixed in 2.6.32 development cycle by this commit -
> db4cfd8a6149e778befb2ff6e6f91cdc6394cbe6 ("netxen: handle firmware load errors").
>
> This added a check for adapter->is_up before touching txq lock.

Yes.  That should prevent the null pointer deference.  Will it also
allow setting the mac address when the NIC is down?

Eric
