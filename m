From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 84061] New: net/batman-adv/gateway_client.c:813: missing
 sanity check and dodgy coding ?
Date: Mon, 8 Sep 2014 17:30:14 -0700
Message-ID: <20140908173014.2946e411@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:54390 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754940AbaIIAaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 20:30:30 -0400
Received: by mail-pa0-f51.google.com with SMTP id kx10so4175743pab.10
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 17:30:29 -0700 (PDT)
Received: from uryu.home.lan ([67.204.147.58])
        by mx.google.com with ESMTPSA id g7sm10053538pdj.7.2014.09.08.17.30.29
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 08 Sep 2014 17:30:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 8 Sep 2014 00:04:40 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 84061] New: net/batman-adv/gateway_client.c:813: missing sanity check and dodgy coding ?


https://bugzilla.kernel.org/show_bug.cgi?id=84061

            Bug ID: 84061
           Summary: net/batman-adv/gateway_client.c:813: missing sanity
                    check and dodgy coding ?
           Product: Networking
           Version: 2.5
    Kernel Version: 3.17-rc4
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: dcb314@hotmail.com
        Regression: No

net/batman-adv/gateway_client.c:813:31: warning: logical not is only applied to
the left hand side of comparison [-Wlogical-not-parentheses]

    gw_node = batadv_gw_node_get(bat_priv, orig_dst_node);
    if (!gw_node->bandwidth_down == 0)
        goto out;

Function batadv_gw_node_get can return NULL, so there's
a missing sanity check there and maybe the if condition
can be reworked for clarity.

-- 
You are receiving this mail because:
You are the assignee for the bug.
