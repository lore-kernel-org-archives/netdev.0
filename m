From: kuznet@ms2.inr.ac.ru
Subject: Re: System crash in tcp_fragment()
Date: Tue, 21 May 2002 16:47:40 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200205211247.QAA05603@sex.inr.ac.ru>
References: <3CE9F679.90ACF597@mvista.com>
Mime-Version: 1.0
Cc: davem@redhat.com, niv@us.ibm.com, ak@suse.de, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, ak@muc.de, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: george@mvista.com (george anzinger)
In-Reply-To: <3CE9F679.90ACF597@mvista.com> from "george anzinger" at May 21, 2 00:25:46 am
List-Id: netdev.vger.kernel.org

Hello!

> I understand the issue.

I do not.


+#define preempt_disable() \
+do { \
+       ++current->preempt_count; \
+       barrier(); \
+} while (0)

Why does this work?

Alexey
