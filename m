From: Pete Zaitcev <zaitcev@redhat.com>
Subject: Re: e1000e fails probe
Date: Mon, 10 May 2010 21:55:42 -0600
Message-ID: <20100510215542.568df79d@redhat.com>
References: <20100510185018.3478bcae@redhat.com>
	<8DD2590731AB5D4C9DBF71A877482A90010D1DE754@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58149 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932555Ab0EKDzf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 May 2010 23:55:35 -0400
In-Reply-To: <8DD2590731AB5D4C9DBF71A877482A90010D1DE754@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 May 2010 18:33:56 -0700
"Allan, Bruce W" <bruce.w.allan@intel.com> wrote:

> Sorry you are having problems with e1000e.  You didn't mention which
> LOM device was on this system - is the PCI device id 0x10ea, 0x10eb,
> 0x10ef or 0x10f0?

lspci -n says:

00:19.0 0200: 8086:10ef (rev 04)

> What BIOS version is on the system?

dmidecode says:

        Vendor: American Megatrends Inc.
        Version: 4.6.3
        Release Date: 05/22/2009

> Would you be able to try a patch that is already in DaveM's net-next-2.6
> tree?  If so, it is
> http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=627c8a041f7aaaea93c766f69bd61d952a277586

Thank you, this works. I guess I should've been more patient.

Yours,
-- Pete
