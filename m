From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH][MCAST]Two fix for implementation of MLDv2 .
Date: Thu, 3 Nov 2005 20:30:57 -0800
Message-ID: <OF70243A3E.F658C3A4-ON882570AF.001699E7-882570AF.0018C8DB@us.ibm.com>
References: <7e77d27c0511030526g45d8f6e6l@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161018AbVKDEav@vger.kernel.org>
In-Reply-To: <7e77d27c0511030526g45d8f6e6l@mail.gmail.com>
To: Yan Zheng <yzcorp@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yan,
        I'm looking at this one. My original interpretation was that a
group and source specific query should only be answered if the source
were explicitly listed (which is what the code does), but I see your 
point.
A general or group-specific query should still be answered with the
existing code, and the unsolicited reports will also include the EXCLUDE
records for that group, so I'm not aware of any actual circumstances
where a multicast router wouldn't forward. But maybe you have such
a case. An administrator-initiated query, however, would certainly be
misleading to the administrator in the example you provided, and so
far I tend to agree that there should be a record in the report.
        However, I'm not sure your solution is appropriate since it
appears to include EXCLUDE records in cases where they aren't
needed.
        So, I'll look at this more carefully and see if I still agree
it needs a fix and whether or not your patch, or some alternative
method might be more appropriate. But it'll probably be sometime
next week before I'll be done reviewing/considering alternatives on
this one.

                                        +-DLS
