From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][2.5] net/core/dev.c readability cleanups
Date: Tue, 11 Jun 2002 05:25:39 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020611.052539.34960972.davem@redhat.com>
References: <Pine.GSO.4.05.10206091807250.16392-200000@mausmaki.cosy.sbg.ac.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@muc.de, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: dent@cosy.sbg.ac.at
In-Reply-To: <Pine.GSO.4.05.10206091807250.16392-200000@mausmaki.cosy.sbg.ac.at>
List-Id: netdev.vger.kernel.org


I don't find this more readable at all.  SUPPORT_2_2 is simply crap,
it isn't 2.2.x anything, it simply means protocols that aren't %100
SMP safe.  Also "uint" doesn't belong in here and doesn't increase
readability at all.

Talk to Arnaldo de Melo if you want to do janitorial work in this
area, when he sends me cleanups I don't barf.
