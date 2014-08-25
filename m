From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 80201] general protection fault: 0000 [#1] SMP (while
 using HTB)
Date: Mon, 25 Aug 2014 14:48:46 -0700
Message-ID: <20140825144846.57afc899@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:62549 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933438AbaHYVst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 17:48:49 -0400
Received: by mail-pd0-f173.google.com with SMTP id w10so21123566pde.32
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 14:48:49 -0700 (PDT)
Received: from urahara (static-50-53-65-80.bvtn.or.frontiernet.net. [50.53.65.80])
        by mx.google.com with ESMTPSA id c6sm779463pbu.59.2014.08.25.14.48.48
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Aug 2014 14:48:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 25 Aug 2014 09:39:23 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 80201] general protection fault: 0000 [#1] SMP (while using HTB)


https://bugzilla.kernel.org/show_bug.cgi?id=80201

--- Comment #12 from Cenek Zach <cenek.zach@gmail.com> ---
I might have a clue. We are changing the limits imposed by HTB each minute
using following command:

$TC class change dev "$BL_DEVICE" parent 1: classid 1:1 htb rate "$LIMIT" burst
"$BL_BURST" cburst "$BL_CBURST" quantum 60000

And this command was definitely running in 3/4 cases at the time of crash
(found him in 'crash> bt -a')

-- 
You are receiving this mail because:
You are the assignee for the bug.
