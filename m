From: Manish Chopra <manish.chopra@qlogic.com>
Subject: RE: [0/2] netxen: bug fix and diagnostics for possible (hardware?)
 bug
Date: Tue, 17 Dec 2013 21:50:52 +0000
Message-ID: <31AFFC7280259C4184970ABA9AFE8B938CF85726@avmb3.qlogic.org>
References: <1387257753-18676-1-git-send-email-david@gibson.dropbear.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	"snagarka@redhat.com" <snagarka@redhat.com>,
	"tcamuso@redhat.com" <tcamuso@redhat.com>,
	"vdasgupt@redhat.com" <vdasgupt@redhat.com>
To: David Gibson <david@gibson.dropbear.id.au>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:53777 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752004Ab3LQVvD convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 16:51:03 -0500
In-Reply-To: <1387257753-18676-1-git-send-email-david@gibson.dropbear.id.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Gibson [mailto:david@gibson.dropbear.id.au]
>Sent: Tuesday, December 17, 2013 10:53 AM
>To: Manish Chopra; Sony Chacko; Rajesh Borundia
>Cc: netdev; snagarka@redhat.com; tcamuso@redhat.com;
>vdasgupt@redhat.com
>Subject: [0/2] netxen: bug fix and diagnostics for possible (hardware?) bug
>
>At Red Hat, we've hit a couple of customer cases with crashes in the netxen driver
>due to list corruption.  This seems to be very rarely triggered, and unfortunately
>the dumps we have don't have enough information to be certain of the cause,
>although we have a possible theory.
>
>I'm suggesting, therefore a patch to add some sanity checking which should help
>to at least localize and mitigate the problem when someone hits it in future.
>Please let me know if there's a better approach to doing this.
>
>That's 2/2.  1/2 is a fix for a clear bug I spotted along the way, but not one that
>could cause the symptoms we've seen.

David,

Having these checks in data path(Rx path) may have some performance impact. It's better to root cause it instead of putting some sanity checks.
We will get back to you on this.


Thanks
Manish
