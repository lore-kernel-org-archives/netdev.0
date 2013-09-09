From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/3] Send comm and cmdline in SCM_PROCINFO
Date: Sun, 08 Sep 2013 23:52:44 -0700
Message-ID: <878uz6bi6b.fsf@xmission.com>
References: <1377614400-27122-1-git-send-email-jkaluza@redhat.com>
	<1377614400-27122-3-git-send-email-jkaluza@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, eparis@redhat.com, rgb@redhat.com
To: Jan Kaluza <jkaluza@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58516 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795Ab3IIGww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 02:52:52 -0400
In-Reply-To: <1377614400-27122-3-git-send-email-jkaluza@redhat.com> (Jan
	Kaluza's message of "Tue, 27 Aug 2013 16:39:59 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Kaluza <jkaluza@redhat.com> writes:

Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Whatever the benefits of the other pieces of information sending the
process command line is absolutely wrong.  It is a just a random string
from user space and there is absolutely no benefit in sending it in a
kernel verified way.  The process can just as easily pass the
information in userspace directly.

Furthermore the implementation of scm_get_current_procinfo is so far
from idiomatic for reading information about the current process that I
think it is fair to call it broken.

Eric
