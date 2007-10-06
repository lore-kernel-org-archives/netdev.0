From: Abhijit Menon-Sen <ams@toroid.org>
Subject: duplicated u32 filters in tc show output
Date: Sat, 6 Oct 2007 18:40:56 +0530
Message-ID: <20071006131056.GA17693@toroid.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fugue.toroid.org ([85.10.196.113]:1964 "EHLO fugue.toroid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756126AbXJFNeN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Oct 2007 09:34:13 -0400
Received: from penne (localhost [127.0.0.1])
	by fugue.toroid.org (Postfix) with ESMTP id 1EC958B60
	for <netdev@vger.kernel.org>; Sat,  6 Oct 2007 15:10:57 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The HTB user guide (http://luxik.cdi.cz/~devik/qos/htb/manual/userg.htm)
says the following:

    Note: The U32 classifier has an undocumented design bug which causes
    duplicate entries to be listed by "tc filter show" when you use U32
    classifiers with different prio values.

What exactly is this bug? (I'm seeing its effects, i.e. the duplicates,
and it's making my life a little difficult while trying to parse the tc
output.)

-- ams
