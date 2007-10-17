From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Will RFC1146 (tcp alternative checksum options) be implemented in Linux tcp stack ?
Date: 17 Oct 2007 02:29:37 +0200
Message-ID: <p73sl4ay45q.fsf@crumb.suse.de>
References: <887901.30138.qm@web55205.mail.re4.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Yanping Du <ypdu2001@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:41979 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753615AbXJQA3j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 20:29:39 -0400
In-Reply-To: <887901.30138.qm@web55205.mail.re4.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yanping Du <ypdu2001@yahoo.com> writes:

>   We found the standard 16-bit tcp checksum is not
> strong enough in some cases. Is there any roadmap on
> implementing RFC1146 (tcp alternative checksum
> options) in Linux tcp stack ?

The standard way to solve this problem is to either use
SSL or IPSec.  They both use very strong checksums
and are widely supported unlike this obscure old RFC.

-Andi
