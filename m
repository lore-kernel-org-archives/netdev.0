From: Hasso Tepper <hasso@estpak.ee>
Subject: Sysctl syscall
Date: Wed, 15 Nov 2006 21:05:52 +0200
Message-ID: <200611152105.53391.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from test.estpak.ee ([194.126.115.47]:9705 "EHLO devy.estpak.ee")
	by vger.kernel.org with ESMTP id S1423742AbWKPKh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Nov 2006 05:37:59 -0500
To: netdev@vger.kernel.org, lkml@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Compiling the program which uses a lot "sysctl" syscalls, gives me this 
warning on Debian unstable:

"warning: the `sysctl' syscall has been removed from 2.6.18+ kernels, 
direct access to `/proc/sys' should be used instead."

Is it true? And what can be used as alternative which would work with both 
2.4 and 2.6 kernels and would work with capabilities (sys/capability.h)?
Accessing `/proc/sys' directly isn't such alternative as it doesn't work 
with capabilities.


regards,

-- 
Hasso Tepper
Elion Enterprises Ltd. [AS3249]
Data Communication Network Administrator
