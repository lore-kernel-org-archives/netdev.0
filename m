From: Jan Olderdissen <jan@ixiacom.com>
Subject: RE: MSEC_TO_JIFFIES is messed up...
Date: Wed, 12 May 2004 13:40:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15FDCE057B48784C80836803AE3598D50627ACD5@racerx.ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: davidel@xmailserver.org, jgarzik@pobox.com, greg@kroah.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Andrew Morton'" <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Couple nitpicks:

> #if HZ=1000

#if HZ==1000

> #define	MSEC_TO_JIFFIES(msec) (msec)
> #define JIFFIES_TO_MESC(jiffies) (jiffies)
> #elif HZ=100

#elif HZ==100

> #define	MSEC_TO_JIFFIES(msec) (msec * 10)
> #define JIFFIES_TO_MESC(jiffies) (jiffies / 10)

#define JIFFIES_TO_MSEC(jiffies) (jiffies / 10)

> #else
> #define	MSEC_TO_JIFFIES(msec) ((HZ * (msec) + 999) / 1000)
> #define	JIFFIES_TO_MSEC(jiffies) ...
> #endif

Jan
