From: kuznet@ms2.inr.ac.ru
Subject: Re: Frozen machine with adding a tc filter
Date: Wed, 24 Jul 2002 02:19:53 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200207232219.CAA16865@sex.inr.ac.ru>
References: <20020723221142.GA15146@outpost.ds9a.nl>
Mime-Version: 1.0
Cc: albertogli@telpin.COM.AR, netdev@oss.sgi.com, jdike@karaya.com
Return-path: <owner-netdev@oss.sgi.com>
To: ahu@ds9a.nl (bert hubert)
In-Reply-To: <20020723221142.GA15146@outpost.ds9a.nl> from "bert hubert" at Jul 24, 2 00:11:42 am
List-Id: netdev.vger.kernel.org

Hello!

> In the last command, cbq_bind_filter is called with parent==0:

Damn, indeed. Congratulations!

It should look like:

+	if (p == NULL)
+	         p = &q->link;
        if (cl) {
-                if (p && p->level <= cl->level)
+                if (p->level <= cl->level)
                        return 0;
                 cl->filters++;


Alexey
