From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 60669] Kernel panic when using negative priority for HTB
 class
Date: Thu, 1 Aug 2013 21:12:31 -0700
Message-ID: <20130801211231.1b25c3be@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f195.google.com ([209.85.192.195]:64775 "EHLO
	mail-pd0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978Ab3HBEMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 00:12:36 -0400
Received: by mail-pd0-f195.google.com with SMTP id u10so95055pdi.10
        for <netdev@vger.kernel.org>; Thu, 01 Aug 2013 21:12:36 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-71-109.bvtn.or.frontiernet.net. [50.53.71.109])
        by mx.google.com with ESMTPSA id ue9sm7337037pab.7.2013.08.01.21.12.34
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 01 Aug 2013 21:12:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 1 Aug 2013 02:38:53 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 60669] Kernel panic when using negative priority for HTB class


https://bugzilla.kernel.org/show_bug.cgi?id=60669

_Vi <vi0oss@gmail.com> changed:

           What    |Removed                     |Added
----------------------------------------------------------------------------
            Summary|Kernel panic when using HTB |Kernel panic when using
                   |qdisc                       |negative priority for HTB
                   |                            |class

--- Comment #2 from _Vi <vi0oss@gmail.com> ---
Reproducible on 3.11.0-rc3

Looks like negative priority value is essential for the kernel panic.

-- 
You are receiving this mail because:
You are the assignee for the bug.
