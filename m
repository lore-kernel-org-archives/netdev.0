From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch next 3/4] netxen: fix bonding support
Date: Mon, 26 Oct 2009 22:50:32 -0700
Message-ID: <m1aazdl713.fsf@fess.ebiederm.org>
References: <1241586309-12112-1-git-send-email-dhananjay@netxen.com>
	<1241586309-12112-4-git-send-email-dhananjay@netxen.com>
	<m1ljj2ps80.fsf@fess.ebiederm.org>
	<7608421F3572AB4292BB2532AE89D5658B0B6E4F72@AVEXMB1.qlogic.org>
	<m1skd9letu.fsf@fess.ebiederm.org>
	<7608421F3572AB4292BB2532AE89D5658B0B6E4F74@AVEXMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:57173 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755762AbZJ0Fub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 01:50:31 -0400
In-Reply-To: <7608421F3572AB4292BB2532AE89D5658B0B6E4F74@AVEXMB1.qlogic.org> (Dhananjay Phadke's message of "Sat\, 24 Oct 2009 10\:29\:50 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dhananjay Phadke <dhananjay.phadke@qlogic.com> writes:

>> Yes.  That should prevent the null pointer deference.  Will it also
>> allow setting the mac address when the NIC is down?
>> 
>> Eric
>
> Yes, we do save new address in netdev->dev_addr.
> This is later on programmed in hardware when interface is brought up.

Yep. Thanks.  I just tested it and confirmed the crash is no longer there.

Eric
